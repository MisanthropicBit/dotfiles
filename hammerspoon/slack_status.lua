local slack_status = {}

local config = require("config")
local slack = require("slack")

local function updateStatus()
    slack.updateStatus("Working remotely", slack.emojis.wfh, 0, config.slack_token)
end

function slack_status.init()
    if type(config.slack_token) ~= "string" then
        return
    end

    ---@diagnostic disable-next-line: unused-local
    hs.wifi.watcher.new(function(_watcher, message, interface)
        local newNetwork = hs.wifi.currentNetwork()

        if newNetwork ~= nil and not config.at_work then
            updateStatus()
        end
    end):watchingFor({ "SSIDChange" }):start()

    ---@diagnostic disable-next-line: unused-local
    hs.application.watcher.new(function(name, event, app)
        if name == "Slack" and event == hs.application.watcher.launched then
            if not config.at_work then
                updateStatus()
            end
        end
    end)
end

return slack_status
