local notify = {}

local notifier = nil

if vim.g.custom_notifier == 'terminal-notifier' then
    local command = vim.g.custom_notifier .. ' -title "%s" -message "%s"'

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
            notifier(msg, level, options)
        else
            old_vim_notify(msg, level, options)
        end
    end
end

return notify
