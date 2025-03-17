local hyper = {}

local config = require("config")
local notify = require("notify")
local remap = require("utils.remap")

---@class HyperConfigKeyMap
---@field key    string
---@field type   "launch" | "bundleId" | "caffeinate"
---@field target string

---@class HyperConfigRemap
---@field source string
---@field target string

---@class HyperConfig
---@field strategy "merge"
---@field hyperKey string
---@field remap? HyperConfigRemap
---@field keymaps HyperConfigKeyMap[]

local keymap_actions = {
  launch = hs.application.launchOrFocus,
  bundleId = hs.application.launchOrFocusByBundleID,
  caffeinate = hs.caffeinate,
}

---@param hyperMode unknown
---@param keymaps HyperConfigKeyMap
local function bindHyperKeys(hyperMode, keymaps)
    for _, keymap in ipairs(keymaps) do
        local action = keymap_actions[keymap.type]
        local target = keymap.target

        if not action then
            notify.error(("Unknown hyper action for key '%s'"):format(keymap.key))
        end

        hyperMode:bind({}, keymap.key, function()
            if keymap.type == "caffeinate" then
                hs.caffeinate[target]()
            else
                action(target)
            end
        end)
    end
end

local function setupHyperKey(hyperKeyConfig)
    local hyperRemap = hyperKeyConfig.remap

    if hyperRemap then
        if not hyperRemap.source or not hyperRemap.target then
            notify.error("Hyper config remap missing 'source' and/or 'target'")
            return
        end

        local sourceId = tonumber(hyperRemap.source)
        local targetId = tonumber(hyperRemap.target)

        if not sourceId or not targetId then
            notify.error("Hyper config remap has invalid 'source' and/or 'target' number")
            return
        end

        local ok = remap.set(sourceId, targetId)

        if not ok then
            local sourceName = hyperRemap.sourceName or "?"
            local targetName = hyperRemap.targetName or "?"

            notify.error(("Failed remap '%s' => '%s'"):format(sourceName, targetName))

            return
        end
    end

    -- Create a new modal state that cannot be activated but lets us manually
    -- toggle it and bind stateful keybinds to it
    local hyperMode = hs.hotkey.modal.new({}, nil)

    -- A global hotkey for toggling the above model state. Using hidutil, capslock
    -- is remapped to F18
    hs.hotkey.bind({}, hyperKeyConfig.hyperKey, function()
        hyperMode:enter()
    end, function()
        hyperMode:exit()
    end)

    bindHyperKeys(hyperMode, hyperKeyConfig.keymaps)
end

function hyper.init()
    local path = os.getenv("HOME") .. "/.hammerspoon/configs/hyper.json"

    local hyperConfig = config.read(path)

    if hyperConfig == nil then
        notify.error(("Failed to read hyper config file '%s'"):format(path))
        return
    end

    ---@cast hyperConfig HyperConfig

    for _, hyperKeyConfig in ipairs(hyperConfig) do
        setupHyperKey(hyperKeyConfig)
    end
end

return hyper
