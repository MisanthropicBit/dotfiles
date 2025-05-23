local builtin = "Built-in Retina Display"

local workScreens = {
    monitor1 = "LG ULTRAFINE (1)",
    monitor2 = "LG ULTRAFINE (2)",
}

local wfhScreens = {
    monitor = "DELL S2721DGF",
}

---@type LayoutConfig
return {
    work = {
        condition = function(context)
            -- This ensures that we only apply the layout when all screens are connected
            return context.screenCount == 3
        end,
        layout = {
            { "1Password",           nil, builtin,              hs.layout.maximized, nil, nil },
            { "Brave Browser",       nil, workScreens.monitor2, hs.layout.maximized, nil, nil },
            { "Datagrip",            nil, workScreens.monitor2, hs.layout.maximized, nil, nil },
            { "Hammerspoon Console", nil, workScreens.monitor2, hs.layout.maximized, nil, nil },
            { "Slack",               nil, builtin,              hs.layout.maximized, nil, nil },
            { "iTerm2",              nil, workScreens.monitor1, hs.layout.maximized, nil, nil },
        },
    },
    wfh = {
        condition = function(context)
            return context.screenCount == 2
        end,
        layout = {
            { "1Password",           nil, builtin,            hs.layout.maximized, nil, nil },
            { "Brave Browser",       nil, wfhScreens.monitor, hs.layout.maximized, nil, nil },
            { "Datagrip",            nil, wfhScreens.monitor, hs.layout.maximized, nil, nil },
            { "Hammerspoon Console", nil, builtin,            hs.layout.maximized, nil, nil },
            { "Slack",               nil, builtin,            hs.layout.maximized, nil, nil },
            { "iTerm",               nil, wfhScreens.monitor, hs.layout.maximized, nil, nil },
        },
    },
}
