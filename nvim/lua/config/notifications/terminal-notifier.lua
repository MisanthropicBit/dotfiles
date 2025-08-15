local sounds = require("config.notifications.sounds")
local utils = require("config.notifications.utils")

return setmetatable({}, {
    __call = function(_, builtin_notify)
        ---@param msg string
        ---@param level integer
        ---@param options table
        return function(msg, level, options)
            local _options = options or {}
            local _title, _msg = utils.transform_message(_options.title, msg)
            local filter = utils.filter_notification(_title, _msg, level, _options, builtin_notify)

            if filter then
                return
            end

            _msg = utils.escape_message(_msg)

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

            local sound = sounds.from_options(level, _options)

            if sound then
                vim.list_extend(command, { "-sound", '"' .. sound .. '"' })
            end

            utils.run_async_command(command, builtin_notify)
        end
    end,
})
