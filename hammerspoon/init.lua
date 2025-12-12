local config = require("config")

config.read_default()

hs.logger.setGlobalLogLevel(config.log_level)

require("hyper").init()
require("autoreload").init()
require("slack_status").init()
require("autolayout").init()

local clipboard_tool = hs.loadSpoon("ClipboardTool")

if clipboard_tool then
    clipboard_tool.frequency = 5
    clipboard_tool.show_copied_alert = false
    clipboard_tool:start()
end

---@param eventName string
---@param params table<string, string>
---@diagnostic disable-next-line: unused-local
hs.urlevent.bind("autolayout", function(eventName, params)
    require("autolayout").apply_default()
    require("notify").send("received url event " .. eventName)
end)
