local run = {}

-- TODO:
-- 1. Support tailing tasks where you can see the output as it is being printed.
--    How can we do this with stdout_buffered etc.?

local map = require("config.map")
local FixedSizedQueue = require("config.run.fixed_sized_queue")
local Task = require("config.run.task")
local utils = require("config.run.utils")

---@class config.run.RunOptions
---@field stdin (string | string[])?

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
function run.notify(msg, level)
    vim.notify(msg, level, { title = "config.run" })
end

---@param task config.run.Task
---@param open_options config.run.OpenLastOptions
---@return integer?
function run.open_terminal_buffer(task, open_options)
    if #task:stdout() == 0 and #task:stderr() == 0 then
        run.notify("Task had no output", vim.log.levels.INFO)
        return
    end

    local buffer = vim.api.nvim_create_buf(false, true)
    local formatted_duration, unit = utils.format_duration(task:duration())

    vim.b[buffer].term_title = ("%s (code: %d in %.2f%s)"):format(
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
    vim.api.nvim_feedkeys("gg", "n", false)

    map.n("q", "<cmd>quit<cr>", { buffer = buffer })
    map.n("<c-c>", function()
        task:stop()
        vim.cmd("quit")
    end, { buffer = buffer })

    return buffer
end

---@param task config.run.Task
---@param options config.run.RunOptions?
---@return boolean, string?
function run.run_task(task, options)
    local _options = options or {}

    local started, err = task:start(vim.tbl_extend("force", _options, {
        on_exit = function()
            local level = vim.log.levels.INFO

            if task:exit_code() ~= 0 then
                level = vim.log.levels.ERROR
            end

            running[task:id()] = nil
            history:push(task)

            local formatted_command = utils.format_command(task:command())
            local formatted_duration, unit = utils.format_duration(task:duration())

            run.notify(
                ("'%s' (%d, %.2f%s)"):format(formatted_command, task:exit_code(), formatted_duration, unit),
                level
            )
        end,
    }))

    return started, err
end

---@param command string | string[]
---@param options config.run.RunOptions?
---@diagnostic disable-next-line: unused-local
function run.run(command, options)
    local task = Task.new(command)
    local started, err = run.run_task(task, options)

    if not started then
        run.notify("Failed to start job: " .. err, vim.log.levels.ERROR)
        return
    end

    running[task:id()] = task
    last_run_task = task
end

---@param job_id integer
function run.stop(job_id)
    local job = running[job_id]

    if not job then
        run.notify(("No running job with id %d"):format(job_id), vim.log.levels.ERROR)
        return
    end

    job:stop()
end

---@return table<integer, config.run.Task>
function run.running()
    return running
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

---@param task config.run.Task
function run.set_last_run_task(task)
    last_run_task = task
end

---@return config.run.Task?
function run.last_run_task()
    return last_run_task
end

---@param options config.run.OpenLastOptions?
function run.open_last(options)
    local last_task = run.last()

    if not last_task then
        run.notify("No last job", vim.log.levels.ERROR)
        return
    end

    run.open_terminal_buffer(last_task, options or {})
end

return run
