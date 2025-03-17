---@param src_code integer
---@param dst_code integer
---@param devices table<string, integer>[]?
local function remapKey(src_code, dst_code, devices)
    local handle = io.popen("hidutil property --get 'UserKeyMapping'")

    if handle then
        local result = handle:read("*a")

        if result ~= "(null)\n" then
            handle:close()
            return
        end

        handle:close()
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
    end
end

---@class HyperConfigKeyMap
---@field key     string
---@field type   "launch" | "bundleId" | "caffeinate"
---@field target string

---@class HyperConfig
---@field strategy "merge"
---@field keymaps HyperConfigKeyMap[]

---@param relative_path string
---@return HyperConfig
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

-- Create a new model state that cannot be activated but lets us manually
-- toggle it and bind stateful keybinds to it
local hyper = hs.hotkey.modal.new({}, nil)

-- A global hotkey for toggling the above model state. Using hidutil, capslock
-- is remapped to F18
hs.hotkey.bind({}, "F18", function()
    hyper:enter()
end, function()
    hyper:exit()
end)

local keymap_actions = {
  launch = hs.application.launchOrFocus,
  bundleId = hs.application.launchOrFocusByBundleID,
  caffeinate = hs.caffeinate,
}

for _, keymap in ipairs(hyper_config.keymaps) do
    local action = keymap_actions[keymap.type]
    local target = keymap.target

    if not action then
        hs.notify
            .new({
                title = "Hammerspoon",
                informativeText = ("Error: Unknown hyper action for key '%s'"):format(keymap.key),
            })
            :send()
    end

    hyper:bind({}, keymap.key, function()
        if keymap.type == "caffeinate" then
            hs.caffeinate[target]()
        else
            action(target)
        end
    end)
end
