local notify = {}

local notifier = nil

---@param level integer
---@return boolean
local function should_notify(level)
    if type(vim.g.notify_log_level) == "number" then
        return level >= vim.g.notify_log_level
    end

    return level >= vim.log.levels.INFO
end

if vim.g.custom_notifier then
    local ok, _notifier = pcall(require, "config.notifications." .. vim.g.custom_notifier)

    if not ok then
        error(("Unknown custom notifier '%s'"):format(vim.g.custom_notifier))
    end

    local builtin_vim_notify = vim.notify
    notifier = _notifier(builtin_vim_notify)

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.notify = function(msg, level, options)
        local disabled = vim.g.disable_custom_notifier
        local is_enabled = disabled == nil or (type(disabled) == "boolean" and not disabled)

        if is_enabled or (type(options) == "table" and options.custom == true) then
            if not should_notify(vim.g.notify_log_level) then
                return
            end

            notifier(msg, level, options)
        else
            builtin_vim_notify(msg, level, options)
        end
    end
end

return notify
