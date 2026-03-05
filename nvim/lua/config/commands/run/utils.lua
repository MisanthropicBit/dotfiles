local utils = {}

---@param command string | string[]
---@return string
function utils.format_command(command)
    if type(command) == "string" then
        return command
    end

    local truncated = table.concat(command, " "):sub(1, 50)

    if #command > 50 then
        truncated = truncated .. "..."
    end

    return truncated
end

---@param durationMs integer
---@return integer, string
function utils.format_duration(durationMs)
    -- 222615ms 222.615s 3.71025m
    local units = { "h", "m", "s" }

    for idx = 1, #units do
        local factor = math.pow(60, #units - idx) * 1000

        if durationMs > factor then
            return durationMs / factor, units[idx]
        end
    end

    return durationMs, "ms"
end

return utils
