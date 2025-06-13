local sounds = require("config.notifications.sounds")

return setmetatable({}, {
    __call = function(_, builtin_notify)
        ---@param msg string
        ---@param level integer
        ---@param options table
        return function(msg, level, options)
            local _options = options or {}
            local title = (_options.title or 'neovim')
            local command = { "osascript", "-e" }
            local subcommand = 'display notification "%s" with title "%s"'

            if level and not _options.muted then
                local sound = sounds.get_sound_by_level(level)

                if sound then
                    subcommand = subcommand .. ' sound name "' .. sound .. '"'
                end
            end

            local final_command = ("%s '%s'"):format(
                table.concat(command, " "),
                subcommand:format(msg, title)
            )

            if _options.echo_message == nil or _options.echo_message == true then
                builtin_notify(msg, level, options)
            end

            -- TODO: Replace with async version
            vim.fn.system(final_command)
        end
    end
})
