---@class config.run.TaskStartOptions : config.run.RunOptions
---@field command (string | string[])?
---@field on_exit fun(task: config.run.Task)?

---@class config.run.Task
---@field private _job_id     integer?
---@field private _command    string | string[]
---@field private _stdout     string[]
---@field private _stderr     string[]
---@field private _exit_code  integer?
---@field private _start_time number?
---@field private _end_time   number?
local Task = {}

Task.__index = Task

---@param task config.run.Task
---@param data any
---@param name string
local function output_handler(task, data, name)
    if #data == 1 and data[1] == "" then
        return
    end

    vim.list_extend(task[name], data)
end

---@param command string | string[]
---@return config.run.Task
function Task.new(command)
    ---@type string | string[]
    local expanded_command = command

    if type(command) == "string" then
        expanded_command = vim.fn.expandcmd(command)
    else
        expanded_command = vim.tbl_map(vim.fn.expandcmd, command)
    end

    return setmetatable({
        _command = expanded_command,
        _stdout = {},
        _stderr = {},
        _exit_code = nil,
        _start_time = nil,
        _end_time = nil,
    }, Task)
end

---@param options config.run.TaskStartOptions?
---@return boolean, unknown?
function Task:start(options)
    local _options = options or {}
    local stdin

    if _options.stdin then
        if type(_options.stdin) == "string" then
            stdin = _options.stdin
        else
            ---@diagnostic disable-next-line: param-type-mismatch
            stdin = table.concat(_options.stdin, "\n")
        end
    end

    self._command = _options.command or self._command

    local ok, job_id = pcall(vim.fn.jobstart, self._command, {
        on_exit = function(_, exit_code, _)
            ---@diagnostic disable-next-line: undefined-field
            self._end_time = vim.uv.hrtime()
            self._exit_code = exit_code

            if vim.is_callable(_options.on_exit) then
                _options.on_exit(self)
            end
        end,
        stdin = stdin,
        on_stdout = function(_, data, _)
            output_handler(self, data, "_stdout")
        end,
        stdout_buffered = true,
        on_stderr = function(_, data, _)
            output_handler(self, data, "_stderr")
        end,
        stderr_buffered = true,
        -- Do not process ansi escape sequences so we can display colors later
        -- in a terminal buffer
        pty = true,
    })

    if not ok then
        return false, job_id
    end

    self._job_id = job_id
    ---@diagnostic disable-next-line: undefined-field
    self._start_time = vim.uv.hrtime()

    return true
end

---@return integer?
function Task:id()
    return self._job_id
end

---@return string | string[]
function Task:command()
    return self._command
end

---@return integer?
function Task:exit_code()
    return self._exit_code
end

---@return string[]
function Task:stdout()
    return self._stdout
end

---@return string[]
function Task:stderr()
    return self._stderr
end

---@return boolean
function Task:running()
    return self._start_time ~= nil and self._end_time == nil
end

---@return boolean
function Task:completed()
    return self._start_time ~= nil and self._end_time ~= nil
end

---@return number
function Task:duration()
    if not self:completed() then
        return -1
    end

    return (self._end_time - self._start_time) / 1e6
end

function Task:stop()
    vim.fn.jobstop(self._job_id)
end

---@return config.run.Task
function Task:copy()
    return Task.new(self._command)
end

return Task
