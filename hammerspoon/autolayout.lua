local autolayout = {}

local config = require("config")
local notify = require("notify")

local lastScreenCount = 0

---@class LayoutContext
---@field screenCount integer

---@class LayoutConfigEntry
---@field condition fun(context: LayoutContext): boolean?
---@field layout    any[]

---@alias LayoutConfig table<string, LayoutConfigEntry>

function autolayout.apply(name, options)
    local screenCount = #hs.screen.allScreens()

    if screenCount == 1 then
        notify.send("No layout applied, only one screen")
        return
    end

    local path = "configs.autolayout"
    local autolayoutConfig = config.read(path)

    if autolayoutConfig == nil then
        notify.error(("Failed to read autolayout config file '%s'"):format(path))
        return
    end

    local layoutConfig = autolayoutConfig[name]
    print(hs.inspect(layoutConfig))

    if not layoutConfig then
        notify.error(("No layout found for layout config '%s'"):format(name))
        return
    end

    if options and not options.skipCondition and type(layoutConfig.condition) == "function" then
        if not layoutConfig.condition({ screenCount = options.newScreenCount }) then
            return
        end
    end

    hs.layout.apply(layoutConfig.layout)
end

function autolayout.init()
    local function default_apply_layout(screenCount)
        local _screenCount = screenCount or #hs.screen.allScreens()
        local layoutName = config.at_work and "work" or "wfh"

        autolayout.apply(layoutName, { skipCondition = false, screenCount = _screenCount })
    end

    hs.screen.watcher.new(function()
        local newScreenCount = #hs.screen.allScreens()

        if newScreenCount == 1 then
            return
        end

        if lastScreenCount ~= newScreenCount then
            lastScreenCount = newScreenCount

            default_apply_layout(newScreenCount)
        end
    end):start()

    local caffeinateWatcher = hs.caffeinate.watcher.new(function(event)
        if event == hs.caffeinate.watcher.screensDidUnlock then
            default_apply_layout()
        end
    end)

    caffeinateWatcher:start()
end

return autolayout
