local utils = {}

---@param msg string
---@return string
function utils.escape_message(msg)
    local escaped = (msg:sub(1, 1) == "[" and "\\" .. msg or msg):gsub('"', '\\"')

    return escaped
end

---@param msg string
---@param title string
---@param level integer
---@param options table
---@param builtin_notify config.notifications.BuiltVimNotify
---@return boolean # If true, filter notification
---@diagnostic disable-next-line: unused-local
function utils.filter_notification(title, msg, level, options, builtin_notify)
    local filter_builtin = false

    if not filter_builtin then
        if options.echo_message == nil or options.echo_message == true then
            builtin_notify(msg, level, options)
        end
    end

    return false
end

---@param msg string
---@param title string
---@return string, string
function utils.transform_message(title, msg)
    local groups = vim.fn.matchlist(msg, [[\v^(SUCCESS|FAILURE) (.+)]])

    if #groups > 0 then
        local status, message = groups[2], groups[3]
        local icon = status == "SUCCESS" and "✅" or "❌"

        return ("overseer.nvim %s"):format(icon), message
    end

    return title, msg
end

---@param command string[]
---@param builtin_notify config.notifications.BuiltVimNotify
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
