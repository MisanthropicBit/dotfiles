local run = {}

-- TODO:
-- 1. Support tailing tasks where you can see the output as it is being printed.
--    How can we do this with stdout_buffered etc.?

local icons = require("config.icons")
local map = require("config.map")
local FixedSizedQueue = require("config.commands.run.fixed_sized_queue")
local Task = require("config.commands.run.task")
local utils = require("config.commands.run.utils")

---@class config.run.OpenLastOptions
---@field split    string?
---@field vertical boolean?
---@field tab      boolean?
---@field edit     boolean?

local history_size = 3

---@type config.FixedSizedQueue<config.run.Task>
local history = FixedSizedQueue.new(history_size)

---@type table<integer, config.run.Task>
local running = {}

---@type config.run.Task?
local last_run_task

---@type table<string, string[]>
local completion_items_by_project_root = {}

---@param msg string
---@param level vim.log.levels
local function notify(msg, level)
    vim.notify(msg, level, { title = "config.run" })
end

-- ---@param task config.run.Task
-- local function format_task(task)
--     local formatted_command = utils.format_command(task:command())
--
--     if task:running() then
--         return ("%s %s (running)"):format(icons.lsp.cmdline, formatted_command)
--     end
--
--     return ("%s %s [exit code: %d] [duration: %dms] [stdout: %d bytes] [stderr %d bytes]"):format(
--         icons.lsp.cmdline,
--         formatted_command,
--         task:exit_code(),
--         task:duration(),
--         #task:stdout(),
--         #task:stderr()
--     )
-- end

---@param task config.run.Task
---@param open_options config.run.OpenLastOptions
local function open_terminal_buffer(task, open_options)
    if #task:stdout() == 0 and #task:stderr() == 0 then
        notify("Task had no output", vim.log.levels.INFO)
        return
    end

    local buffer = vim.api.nvim_create_buf(false, true)
    local formatted_duration, unit = utils.format_duration(task:duration())

    vim.b[buffer].term_title = ("%s (%d) %.2f%s"):format(
        utils.format_command(task:command()),
        task:exit_code(),
        formatted_duration,
        unit
    )

    local term_id = vim.api.nvim_open_term(buffer, {})

    if #task:stdout() > 0 then
        vim.api.nvim_chan_send(term_id, table.concat(task:stdout(), "\n"))
    end

    if #task:stderr() > 0 then
        vim.api.nvim_chan_send(term_id, table.concat(task:stderr(), "\n"))
    end

    local open_command = "sbuffer"

    if open_options then
        if open_options.edit == true then
            open_command = "buffer"
        elseif open_options.split and open_options.split ~= "" then
            open_command = "sbuffer"
        elseif open_options.vertical == true then
            open_command = "vertical sbuffer"
        elseif open_options.tab == true then
            open_command = "tab sbuffer"
        end
    end

    vim.cmd(("%s %d"):format(open_command, buffer))

    -- Exit terminal mode (cannot use normal-mode commands when in terminal mode)
    local replaced_input = vim.api.nvim_replace_termcodes([[<C-\><C-n>]], true, false, true)

    vim.api.nvim_feedkeys(replaced_input, "n", false)
    vim.cmd.normal("gg")

    map.n("q", "<cmd>quit<cr>", { buffer = buffer })
    map.n("<c-c>", function()
        task:stop()
        vim.cmd("quit")
    end, { buffer = buffer })
end

---@param task config.run.Task
---@return boolean, string?
local function run_task(task)
    local started, err = task:start(function()
        local level = vim.log.levels.INFO

        if task:exit_code() ~= 0 then
            level = vim.log.levels.ERROR
        end

        running[task:id()] = nil
        history:push(task)

        local formatted_command = utils.format_command(task:command())
        local formatted_duration, unit = utils.format_duration(task:duration())

        notify(("'%s' (%d, %.2f%s)"):format(formatted_command, task:exit_code(), formatted_duration, unit), level)
    end)

    return started, err
end

---@param command string | string[]
---@param options table?
---@diagnostic disable-next-line: unused-local
function run.run(command, options)
    local task = Task.new(command)
    local started, err = run_task(task)

    if not started then
        notify("Failed to start job: " .. err, vim.log.levels.ERROR)
        return
    end

    running[task:id()] = task
    last_run_task = task
end

---@param job_id integer
function run.stop(job_id)
    local job = running[job_id]

    if not job then
        notify(("No running job with id %d"):format(job_id), vim.log.levels.ERROR)
        return
    end

    job:stop()
end

---@return table<integer, config.run.Task>
function run.running()
    return vim.deepcopy(running)
end

---@return config.run.Task[]
function run.history()
    ---@type config.run.Task[]
    return history:items()
end

---@return config.run.Task?
function run.last()
    local last_job = history:peek()

    if not last_job then
        return
    end

    return last_job
end

---@return config.run.Task?
function run.last_run_task()
    return last_run_task
end

---@param options config.run.OpenLastOptions?
function run.open_last(options)
    local last_task = run.last()

    if not last_task then
        notify("No last job", vim.log.levels.ERROR)
        return
    end

    open_terminal_buffer(last_task, options or {})
end

-- TODO: 'shell' vs none
vim.api.nvim_create_user_command("Run", function(args)
    local run_args = (#args.fargs > 0 and args.fargs) or vim.o.makeprg or (vim.b.run and vim.b.run[1])

    if not run_args then
        notify("No arguments given and no vim.o.makeprg or vim.b.run defined", vim.log.levels.ERROR)
        return
    end

    run.run(run_args)
end, {
    nargs = "*",
    bar = false,
    complete = function(_, cmdline, _)
        local items = { vim.o.makeprg }

        vim.list_extend(items, vim.b.make or {})

        if cmdline == "Run " then
            return items
        end

        return {}
    end,
})

vim.api.nvim_create_user_command("RunAgain", function()
    local last_task = run.last()

    if not last_task then
        notify("No last job", vim.log.levels.ERROR)
        return
    end

    local task_copy = last_task:copy()
    local started, err = run_task(task_copy)

    if not started then
        notify("Failed to start job: " .. err, vim.log.levels.ERROR)
        return
    end

    running[last_task:id()] = task_copy
    last_run_task = task_copy
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

vim.api.nvim_create_user_command("RunPick", function(args)
    local arg = args.fargs[1]
    local pick_type = arg or "history"

    ---@type config.run.Task[]
    local tasks = {}

    if pick_type == "history" then
        tasks = history:items()
    elseif pick_type == "running" then
        tasks = vim.tbl_values(running)
    end

    if #tasks == 0 then
        notify("No jobs", vim.log.levels.INFO)
        return
    end

    ---@param task config.run.Task
    local formatted_tasks = vim.tbl_map(function(task)
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

            vim.list_extend(result, { exit_code, duration })
        else
            table.insert(result, "still running")
        end

        return table.concat(result, " ")
    end, vim.iter(tasks):rev():totable())

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
            open_terminal_buffer(task, options)
        end
    end

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
    }

    if pick_type == "running" then
        actions["ctrl-x"] = {
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
        }
    end

    require("fzf-lua").fzf_exec(formatted_tasks, {
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
        actions = actions,
    })
end, {
    nargs = "?",
    complete = function(_, cmdline, _)
        if cmdline == "RunPick " then
            return { "history", "running" }
        end

        return {}
    end,
})

map.n.leader("rn", "<cmd>Run<cr>")
map.n.leader("rp", "<cmd>RunPick<cr>")
map.n.leader("ra", "<cmd>RunAgain<cr>")

return run
