local sounds = require("config.notifications.sounds")
local utils = require("config.notifications.utils")

return setmetatable({}, {
    __call = function(_, builtin_notify)
        ---@param msg string
        ---@param level integer
        ---@param options table
        return function(msg, level, options)
            local _options = options or {}
            local title = (_options.title or "neovim")

            local _title, _msg = utils.transform_message(_options.title, msg)
            local filter = utils.filter_notification(_title, _msg, level, _options, builtin_notify)

            if filter then
                return
            end

            local command = { "osascript", "-e" }
            local subcommand = 'display notification "%s" with title "%s"'
            local sound = sounds.from_options(level, _options)

            if sound then
                subcommand = subcommand .. ' sound name "' .. sound .. '"'
            end

            local final_command = vim.list_extend(command, { ("'%s'"):format(subcommand:format(msg, title)) })

            utils.run_async_command(final_command, builtin_notify)
        end
    end
})
