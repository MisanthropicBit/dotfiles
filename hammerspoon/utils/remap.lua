local remap = {}

-- To get hexadecimal keycodes, use https://hidutil-generator.netlify.app/
--
-- Use the following to reset: `--set '{"UserKeyMapping":[]}'`
---@param src_code integer
---@param dst_code integer
---@param devices table<string, integer>[]?
---@return boolean
function remap.set(src_code, dst_code, devices)
    local handle = io.popen("hidutil property --get 'UserKeyMapping'")

    if handle then
        local result = handle:read("*a")

        if result ~= "(null)\n" then
            -- Assume it has already been set
            handle:close()
            return true
        end

        handle:close()
    else
        return false
    end

    -- Credit: https://github.com/Hammerspoon/hammerspoon/issues/3512#issuecomment-1661977782
    local mapping = hs.json.encode({
        UserKeyMapping = {
            {
                HIDKeyboardModifierMappingSrc = src_code,
                HIDKeyboardModifierMappingDst = dst_code,
            },
        },
    })

    local command = {
        "/usr/bin/env",
        "hidutil",
        "property",
        "--set",
        "'" .. mapping .. "'",
    }

    for _, device in ipairs(devices or {}) do
        table.insert(command, "--matching")
        table.insert(command, "'" .. hs.json.encode(device) .. "'")
    end

    local status = os.execute(table.concat(command, " "))

    if not status then
        hs.dialog.blockAlert("Remapping failed", "Check with:\nhidutil property --get UserKeyMapping")
        return false
    end

    return true
end

return remap
