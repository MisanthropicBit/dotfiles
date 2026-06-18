local actions = {}

function actions.launch(target, type)
    local resolvedType = type or "launch"

    return function()
        if resolvedType == "launch" then
            hs.application.launchOrFocus(target)
        elseif resolvedType == "bundleId" then
            hs.application.launchOrFocusByBundleID(target)
        else
            error(("Unknown launch type '%s'"):format(type))
        end
    end
end

---@param key string
---@param modifiers string[]?
---@return function
function actions.keyStrokeAction(key, modifiers)
    return function()
        actions.doKeyStroke(key, modifiers)
    end
end

---@param key string
---@param modifiers string[]?
function actions.doKeyStroke(key, modifiers)
    hs.eventtap.event.newKeyEvent(modifiers, key, true):post()
end

return actions
