local map = require("config.map")
local run = require("config.run.run")
local icons = require("config.icons")
local utils = require("config.run.utils")

-- Milliseconds to wait before generating terminal diagnostics to ensure that
-- the terminal buffer has received data sent to its channel
local terminal_buffer_wait_time_ms = 200

local common_fzf_options = {
    prompt = "Select job " .. icons.misc.prompt .. " ",
    header_separator = " | ",
    winopts = {
        width = 0.40,
        height = 0.25,
    },
    fzf_opts = {
        ["--nth"] = "2..",
        ["--with-nth"] = "2..",
    },
}

---@param buffer integer
local function is_clike_extension(buffer)
    ---@diagnostic disable-next-line: param-type-mismatch
    local ext = vim.fn.expand("%:e", vim.api.nvim_buf_get_name(buffer))

    return vim.tbl_contains({ "c", "cpp", "cuda" }, ext)
end

---@param entry string
---@return integer?
local function parse_task_id(entry)
    return tonumber(entry:match("^(%d+)"))
end

---@param id integer
---@param _tasks config.run.Task[]
---@return config.run.Task?
local function find_task(id, _tasks)
    for _, task in ipairs(_tasks) do
        if task:id() == id then
            return task
        end
    end
end

---@param task config.run.Task
---@return string
local function format_task(task)
    local formatted_command = utils.format_command(task:command())
    local icon = require("fzf-lua.utils").ansi_from_hl("Type", icons.lsp.cmdline)
    local command = require("fzf-lua.utils").ansi_from_hl("Title", formatted_command)
    local result = {
        task:id(),
        icon,
        command,
    }

    if task:completed() then
        local formatted_duration, unit = utils.format_duration(task:duration())
        local exit_code = require("fzf-lua.utils").ansi_from_hl("Key", task:exit_code())
        local duration = require("fzf-lua.utils").ansi_from_hl("Label", ("%.2f%s"):format(formatted_duration, unit))

        table.insert(result, ("(code: %s, duration: %s)"):format(exit_code, duration))
    else
        table.insert(result, "still running")
    end

    return table.concat(result, " ")
end

---@param id integer?
---@param _tasks config.run.Task[]
---@param options config.run.OpenLastOptions
---@return config.run.Task?
local function open_task(id, _tasks, options)
    if not id then
        return
    end

    local task = find_task(id, _tasks)

    if task then
        local buffer = run.open_terminal_buffer(task, options)

        if buffer then
            local has_td, tdd = pcall(require, "terminal-diagnostics.diagnostics")

            if has_td then
                -- It is not currently possible to wait for
                -- vim.api.nvim_chan_send although we could probably send
                -- an escape code and get it in a TermRequest or
                -- TermResponse autocmd. Instead we just wait some
                -- milliseconds to ensure that the terminal buffer has
                -- received and processed the input
                vim.defer_fn(function()
                    tdd.create_for_buffer(buffer, { terminal_diagnostics = true, locationlist = true })
                    local diagnostics = vim.diagnostic.get(buffer, { namespace = tdd.namespace_id() })

                    map.n.leader("dl", function()
                        tdd.setloclist(diagnostics)
                    end)

                    map.n.leader("dq", function()
                        tdd.setqflist(diagnostics)
                    end)

                    local td = require("terminal-diagnostics")

                    map.n.leader("ee", function()
                        td.api.open.open({ type = "edit" })
                    end, { buffer = true })

                    map.n.leader("es", function()
                        td.api.open.open({ type = "split" })
                    end, { buffer = true })

                    map.n.leader("ev", function()
                        td.api.open.open({ type = "vertical" })
                    end, { buffer = true })

                    map.n.leader("et", function()
                        td.api.open.open({ type = "tab" })
                    end, { buffer = true })

                    map.n.leader("ew", function()
                        td.api.open.open({ type = "preview" })
                    end, { buffer = true })

                    map.n.leader("ef", function()
                        td.api.open.open({ type = "float" })
                    end, { buffer = true })

                    map.n.leader("ep", function()
                        td.api.jump.jump({ wrap = true, count = -1 })
                    end, { buffer = true })

                    map.n.leader("en", function()
                        td.api.jump.jump({ wrap = true, count = 1 })
                    end, { buffer = true })
                end, terminal_buffer_wait_time_ms)
            end
        end
    end
end

-- TODO: 'shell' vs none ("npa all" does not work with shell)
vim.api.nvim_create_user_command("Run", function(args)
    local run_args

    if #args.fargs > 0 then
        run_args = args.fargs
    elseif vim.o.makeprg then
        if vim.o.makeprg == "make" then
            if is_clike_extension(0) then
                run_args = vim.o.makeprg
            end
        else
            run_args = vim.o.makeprg
        end
    elseif vim.islist(vim.b.run) and #vim.b.run > 0 then
        run_args = vim.b.run[1]
    end

    local options = {}

    if args.range > 0 then
        options.stdin = vim.api.nvim_buf_get_lines(0, args.line1 - 1, args.line2, true)
    end

    if run_args then
        run.run(run_args, options)
    else
        vim.ui.input({ prompt = "Enter command to run: " }, function(input)
            if input and input ~= "" then
                run.run(input, options)
            end
        end)
    end
end, {
    nargs = "*",
    bar = false,
    range = true,
    complete = function(_, cmdline, _)
        local items = { vim.o.makeprg }

        if vim.islist(vim.b.run) then
            vim.list_extend(items, vim.b.run)
        end

        if cmdline:match("Run%s+") then
            return items
        end

        return {}
    end,
})

vim.api.nvim_create_user_command("RunAgain", function()
    local last_task = run.last()

    if not last_task then
        run.notify("No last job", vim.log.levels.ERROR)
        return
    end

    local task_copy = last_task:copy()
    local started, err = run.run_task(task_copy)

    if not started then
        run.notify("Failed to start job: " .. err, vim.log.levels.ERROR)
        return
    end

    run.running()[last_task:id()] = task_copy
    run.set_last_run_task(task_copy)
end, {
    bar = false,
})

vim.api.nvim_create_user_command("RunOpenLast", function(args)
    local smods = args.smods

    run.open_last({
        split = smods.split,
        tab = smods.tab == 1 and true or false,
        vertical = smods.vertical,
    })
end, {})

vim.api.nvim_create_user_command("RunList", function()
    ---@type config.run.Task[]
    local tasks = vim.tbl_values(run.running())

    if #tasks == 0 then
        run.notify("No jobs", vim.log.levels.INFO)
        return
    end

    local formatted_tasks = vim.tbl_map(format_task, vim.iter(tasks):rev():totable())

    local actions = {
        ["default"] = {
            fn = function(selected)
                open_task(parse_task_id(selected[1]), tasks, { edit = true })
            end,
            header = "edit",
        },
        ["ctrl-s"] = {
            fn = function(selected)
                open_task(parse_task_id(selected[1]), tasks, {})
            end,
            header = "open in split",
        },
        ["ctrl-v"] = {
            fn = function(selected)
                open_task(parse_task_id(selected[1]), tasks, { vertical = true })
            end,
            header = "open in vertical split",
        },
        ["ctrl-t"] = {
            fn = function(selected)
                open_task(parse_task_id(selected[1]), tasks, { tab = true })
            end,
            header = "open in tab",
        },
        ["ctrl-x"] = {
            fn = function(selected)
                local id = tonumber(selected[1]:match("^(%d+)"))

                if not id then
                    return
                end

                local task = find_task(id, tasks)

                if task then
                    task:stop()
                end
            end,
            header = "stop job",
        },
    }

    require("fzf-lua").fzf_exec(formatted_tasks, vim.tbl_extend("force", common_fzf_options, { actions = actions }))
end, {
    nargs = 0,
})

vim.api.nvim_create_user_command("RunListHistory", function()
    local tasks = run.history()

    if #tasks == 0 then
        run.notify("No jobs in history", vim.log.levels.INFO)
        return
    end

    local formatted_tasks = vim.tbl_map(format_task, vim.iter(tasks):rev():totable())

    local actions = {
        ["default"] = {
            fn = function(selected)
                open_task(parse_task_id(selected[1]), tasks, { edit = true })
            end,
            header = "edit",
        },
        ["ctrl-s"] = {
            fn = function(selected)
                open_task(parse_task_id(selected[1]), tasks, {})
            end,
            header = "open in split",
        },
        ["ctrl-v"] = {
            fn = function(selected)
                open_task(parse_task_id(selected[1]), tasks, { vertical = true })
            end,
            header = "open in vertical split",
        },
        ["ctrl-t"] = {
            fn = function(selected)
                open_task(parse_task_id(selected[1]), tasks, { tab = true })
            end,
            header = "open in tab",
        },
        ["ctrl-r"] = {
            fn = function(selected)
                local id = tonumber(selected[1]:match("^(%d+)"))

                if not id then
                    return
                end

                local task = find_task(id, tasks)

                if task then
                    run.run_task(task:copy())
                end
            end,
            header = "run again",
        },
    }

    require("fzf-lua").fzf_exec(formatted_tasks, vim.tbl_extend("force", common_fzf_options, { actions = actions }))
end, {
    nargs = 0,
})
