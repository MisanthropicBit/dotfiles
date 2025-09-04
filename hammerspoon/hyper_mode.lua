---@class HyperMode
---@field _mode hs.hotkey.modal
local HyperMode = {}

---@class HyperModeBindOptions
---@field preventRetrigger boolean?

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

---@param mods string[]?
---@param key string
---@param action fun(options: table)
---@param options HyperModeBindOptions?
function HyperMode:bind(mods, key, action, options)
    local _mods = mods or {}

    if options and options.preventRetrigger == true then
        local newAction = function()
            -- Avoid retriggering action when e.g. sending keystrokes
            -- programmatically by exiting and entering the hyper mode around
            -- the action
            self._mode:exit()
            action(options)
            self._mode:enter()
        end

        self._mode:bind(_mods, key, nil, newAction, nil, newAction)
    else
        self._mode:bind(_mods, key, nil, action, nil, action)
    end
end

function HyperMode:enter()
    self._mode:enter()
end

function HyperMode:exit()
    self._mode:exit()
end

return HyperMode
