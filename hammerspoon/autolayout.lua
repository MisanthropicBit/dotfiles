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

function autolayout.autolayout(newScreenCount, autolayoutConfig)
    local layoutName = config.at_work and "work" or "wfh"
    local layoutConfig = autolayoutConfig[layoutName]

    if not layoutConfig then
        notify.error(("No layout found for layout config '%s'"):format(layoutName))
        return
    end

    if type(layoutConfig.condition) == "function" then
        if not layoutConfig.condition({ screenCount = newScreenCount }) then
            return
        end
    end

    hs.layout.apply(layoutConfig.layout)
end

function autolayout.init()
    local path = "configs.autolayout"
    local autolayoutConfig = config.read(path)

    if autolayoutConfig == nil then
        notify.error(("Failed to read autolayout config file '%s'"):format(path))
        return
    end

    hs.screen.watcher.new(function()
        local newScreenCount = #hs.screen.allScreens()

        if newScreenCount == 1 then
            return
        end

        if lastScreenCount ~= newScreenCount then
            lastScreenCount = newScreenCount
            autolayout.autolayout(newScreenCount, autolayoutConfig)
        end
    end):start()
end

return autolayout
