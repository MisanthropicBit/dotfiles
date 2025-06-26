local utils = {}

---@param msg string
---@return string
function utils.escape_message(msg)
    local escaped = (msg:sub(1, 1) == "[" and "\\" .. msg or msg):gsub('"', '\\"')

    return escaped
end

---@param msg string
---@param title string
---@return boolean # If true, filter notification
---@return boolean # If true, filter builtin notification
---@diagnostic disable-next-line: unused-local
function utils.filter_notification(msg, title)
    return false, false
end

---@param command string[]
---@param builtin_notify fun(msg: string, level: integer?, opts: table?)
---@param options vim.SystemOpts?
---@param on_exit? fun(out: vim.SystemCompleted)
function utils.run_async_command(command, builtin_notify, options, on_exit)
    local _options = options or { text = true }

    vim.system(command, _options, function(result)
        if result.code ~= 0 then
            local err_msg = ("Notification failed with code %d and message: %s"):format(result.code, result.stderr)

            builtin_notify(err_msg, vim.log.levels.ERROR)
        end

        if on_exit then
            on_exit(result)
        end
    end)
end

return utils
