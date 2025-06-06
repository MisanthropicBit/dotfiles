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

return actions
