local sounds = {}

local severity_sounds = {
    [vim.log.levels.INFO] = nil,
    [vim.log.levels.TRACE] = nil,
    [vim.log.levels.DEBUG] = nil,
    [vim.log.levels.INFO] = nil,
    [vim.log.levels.WARN] = "Ping",
    [vim.log.levels.ERROR] = "Sosumi",
}

---@param level integer
---@return string?
function sounds.get_sound_by_level(level)
    local sound = severity_sounds[level]

    if sound ~= nil and #sound > 0 then
        return sound
    end

    return nil
end

return sounds
