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

---@param name string
---@return boolean
local function default_condition(name)
    return vim.fn.executable(name) == 1
end

---@type { [1]: string, condition: fun(name: string): boolean }[]
local notifiers = {
    {
        "neovim-notification",
        condition = function()
            ---@diagnostic disable-next-line: undefined-field
            local stat, _, _ = vim.uv.fs_stat("/Applications/NeovimNotification.app")

            return stat ~= nil
        end,
    },
    { "terminal-notifier", condition = default_condition },
    { "osascript", condition = default_condition },
}

local builtin_vim_notify = vim.notify

for _, notifier_spec in ipairs(notifiers) do
    local name, condition = notifier_spec[1], notifier_spec.condition
    local ok, _notifier = pcall(require, "config.notifications." .. name)

    if ok and condition(name) then
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

        break
    end
end

function notify.builtin(...)
    builtin_vim_notify(...)
end

return notify
