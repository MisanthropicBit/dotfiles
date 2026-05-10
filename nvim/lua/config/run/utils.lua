local utils = {}

---@param command string | string[]
---@return string
function utils.format_command(command)
    ---@diagnostic disable-next-line: param-type-mismatch
    local command_string = type(command) == "string" and command or table.concat(command, " ")

    if #command_string < 50 then
        return command_string
    else
        return command_string:sub(1, 50) .. "..."
    end
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
