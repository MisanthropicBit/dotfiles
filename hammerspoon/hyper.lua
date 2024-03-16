---@param src_code integer
---@param dst_code integer
local function remapKey(src_code, dst_code)
    local mapping = hs.json.encode({
        UserKeyMapping = {
            {
                HIDKeyboardModifierMappingSrc = src_code,
                HIDKeyboardModifierMappingDst = dst_code,
            },
        },
    })

    local status = os.execute(table.concat({
        "/usr/bin/env",
        "hidutil",
        "property",
        -- "--match",
        -- '{"VendorID": 0x0, "ProductId": 0x0}',
        -- "--match",
        -- '{"VendorID": 0x4c, "ProductId": 0x26c}',
        "--set",
        "'" .. mapping .. "'",
    }, " "))

    if not status then
        hs.dialog.blockAlert("Remapping failed", "Check with:\nhidutil property --get UserKeyMapping")
    end
end

---@param relative_path string
---@return table<string, string>
local function loadHyperConfig(relative_path)
    local local_config_path = relative_path:sub(1, -6) .. ".local.json"
    local hyper_config = hs.json.read(local_config_path)

    if hyper_config == nil then
        hyper_config = hs.json.read(relative_path)
    end

    return hyper_config
end

-- Remap capslock to F18. To get hexadecimal keycodes, use https://hidutil-generator.netlify.app/
--
-- Use the following to reset: `--set '{"UserKeyMapping":[]}'`
remapKey(0x700000039, 0x70000006D)

local hyper_config = loadHyperConfig(os.getenv("HOME") .. "/.hammerspoon/hyper.json")

if hyper_config == nil then
    hs.notify
        .new({
            title = "Hammerspoon",
            informativeText = "Error: Failed to read hyper config file",
        })
        :send()

    return
end

local hyper = hs.hotkey.modal.new()

hs.hotkey.bind({}, "F18", function()
    hyper:enter()
end, function()
    hyper:exit()
end)

for _, config in ipairs(hyper_config.keymaps) do
    local action

    if config.launch then
        action = hs.application.launchOrFocus
    elseif config.caffeinate then
        action = hs.caffeinate
    else
        hs.notify
            .new({
                title = "Hammerspoon",
                informativeText = ("Error: Unknown hyper action for key '%s'"):format(config.key),
            })
            :send()
    end

    hyper:bind({}, config.key, function()
        action(config.launch)
    end)
end
