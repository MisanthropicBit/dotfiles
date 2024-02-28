local sounds = require("config.notifications.sounds")

---@param msg string
---@return string
local function escape_message(msg)
    local escaped = (msg:sub(1, 1) == "[" and "\\" .. msg or msg):gsub('"', '\\"')

    return escaped
end

return setmetatable({}, {
    __call = function(_, builtin_notify)
        ---@param msg string
        ---@param level integer
        ---@param options table
        return function(msg, level, options)
            local _options = options or {}
            local _msg = escape_message(msg)
            local command = {
                vim.g.custom_notifier,
                "-title",
                '"' .. (_options.title or 'neovim') .. '"',
                "-message",
                '"' .. _msg .. '"'
            }

            if _options.icon and #_options.icon > 0 then
                vim.list_extend(command, { "-contentImage", '"' .. _options.icon .. '"' })
            end

            if level and not _options.muted then
                local sound = sounds.get_sound_by_level(level)

                if sound ~= nil and #sound > 0 then
                    vim.list_extend(command, { "-sound", '"' .. sound .. '"' })
                end
            end

            builtin_notify(msg, level, options)
            vim.fn.system(table.concat(command, " "))
        end
    end
})
