local HyperMode = {}

HyperMode.__index = HyperMode

---@param key string
function HyperMode.new(key)
    -- Create a new modal state that cannot be activated but lets us manually
    -- toggle it and bind stateful keybinds to it
    local hyperMode = hs.hotkey.modal.new({}, nil)

    hs.hotkey.bind({}, key, function()
        hyperMode:enter()
    end, function()
        hyperMode:exit()
    end)

    return setmetatable({ key = key, _mode = hyperMode }, HyperMode)
end

function HyperMode:bind(mods, key, action)
    self._mode:bind(mods, key, action)
end

return HyperMode
