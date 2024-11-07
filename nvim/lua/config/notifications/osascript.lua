local sounds = require("config.notifications.sounds")

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
            subcommand = subcommand .. ' -sound "' .. sound .. '"'
        end
    end

    vim.print("yas")
    local final_command = ("%s '%s'"):format(
        table.concat(command, " "),
        subcommand:format(msg, title)
    )
    vim.print(final_command)

    vim.fn.system(final_command)
end
