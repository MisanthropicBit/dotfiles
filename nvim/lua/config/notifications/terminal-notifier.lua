local sounds = require("config.notifications.sounds")
local utils = require("config.notifications.utils")

return setmetatable({}, {
    __call = function(_, builtin_notify)
        ---@param msg string
        ---@param level integer
        ---@param options table
        return function(msg, level, options)
            local _options = options or {}
            local filter, filter_builtin = utils.filter_notification(msg, _options.title)

            if not filter_builtin then
                if _options.echo_message == nil or _options.echo_message == true then
                    builtin_notify(msg, level, options)
                end
            end

            if not filter then
                local _msg = utils.escape_message(msg)
                local command = {
                    "terminal-notifier",
                    "-title",
                    '"' .. (_options.title or "neovim") .. '"',
                    "-message",
                    '"' .. _msg .. '"',
                }

                if _options.icon and #_options.icon > 0 then
                    vim.list_extend(command, { "-contentImage", '"' .. _options.icon .. '"' })
                end

                if level and not _options.muted then
                    local sound = _options.sound or sounds.get_sound_by_level(level)

                    if sound ~= nil and #sound > 0 then
                        vim.list_extend(command, { "-sound", '"' .. sound .. '"' })
                    end
                end

                utils.run_async_command(command, builtin_notify)
            end
        end
    end,
})
