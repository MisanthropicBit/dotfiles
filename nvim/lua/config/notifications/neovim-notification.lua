local sounds = require("config.notifications.sounds")
local utils = require("config.notifications.utils")

return setmetatable({}, {
    __call = function(_, builtin_notify)
        ---@param msg string
        ---@param level integer
        ---@param options config.NotificationOptions
        return function(msg, level, options)
            local _options = options or {}
            local _title, _msg = utils.transform_message(_options.title, msg)
            local filter = utils.filter_notification(_title, _msg, level, _options, builtin_notify)

            if filter then
                return
            end

            local command = {
                "open",
                "/Applications/NeovimNotification.app",
                "--args",
                _msg,
                (_title or 'Neovim'),
            }

            local sound = sounds.from_options(level, _options)

            if sound then
                table.insert(command, '"' .. sound .. '"')
            end

            utils.run_async_command(command, builtin_notify)
        end
    end
})
