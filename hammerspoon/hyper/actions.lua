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

function actions.keyStroke(key, modifiers)
    return function()
        hs.eventtap.event.newKeyEvent(modifiers, key, true):post()
    end
end

return actions
