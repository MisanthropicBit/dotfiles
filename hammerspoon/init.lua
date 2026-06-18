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
    clipboard_tool.paste_on_select = true
    clipboard_tool:start()
end

local zero_offset = hs.loadSpoon("ZeroOffset")

zero_offset:init()
zero_offset:start()
zero_offset:toggleShowUtc()
