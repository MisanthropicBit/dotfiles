local notify = {}

local notifier = nil

---@param level integer
local function should_notify(level)
    return type(vim.g.notify_log) ~= "number" and level >= vim.g.notify_log_level
end

if vim.g.custom_notifier == 'terminal-notifier' then
    -- Use neovide logo if installed since -appIcon does not appear to work on
    -- my machine
    local command = vim.g.custom_notifier .. ' -sender "com.neovide.neovide" -title "%s" -message "%s"'

    if vim.fn.executable(vim.g.custom_notifier) then
        ---@diagnostic disable-next-line: unused-local
        notifier = function(msg, level, options)
            local _options = options or {}
            local title = (_options.title or 'neovim')

            if _options.icon and #_options.icon > 0 then
                command = command .. ' -appIcon "' .. _options.icon .. '"'
            end

            vim.fn.system(command:format(title, msg))
        end
    end
elseif vim.g.custom_notifier == 'osascript' then
    local command = [[osascript -e 'display notification \"%s\" with title \"%s\"']]

    ---@diagnostic disable-next-line: unused-local
    notifier = function(msg, level, options)
        local _options = options or {}
        local title = (_options.title or 'neovim')

        vim.fn.system(command:format(msg, title))
    end
end

if notifier then
    local old_vim_notify = vim.notify

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.notify = function(msg, level, options)
        if vim.g.use_custom_notifier or (type(options) == 'table' and options.mac == true) then
            if not should_notify(vim.g.notify_log_level) then
                return
            end

            notifier(msg, level, options)
        else
            old_vim_notify(msg, level, options)
        end
    end
end

return notify
