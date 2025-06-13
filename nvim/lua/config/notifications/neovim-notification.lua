local sounds = require("config.notifications.sounds")
local utils = require("config.notifications.utils")

return setmetatable({}, {
    __call = function(_, builtin_notify)
        ---@param msg string
        ---@param level integer
        ---@param options table
        return function(msg, level, options)
            local _options = options or {}
            local _msg = utils.escape_message(msg)
            local command = {
                "open",
                "/Applications/NeovimNotification.app",
                "--args",
                _msg,
                (_options.title or 'Neovim'),
            }

            if level and not _options.muted then
                local sound = _options.sound or sounds.get_sound_by_level(level)

                if sound ~= nil and #sound > 0 then
                    table.insert(command, '"' .. sound .. '"')
                end
            end

            if _options.echo_message == nil or _options.echo_message == true then
                builtin_notify(msg, level, options)
            end

            vim.system(command, { text = true }, function(result)
                if result.code ~= 0 then
                    builtin_notify(("Notification failed with code %d and message: %s"):format(result.code, result.stderr))
                end
            end)
        end
    end
})
