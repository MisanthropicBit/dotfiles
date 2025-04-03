local slack_status = {}

local config = require("config")
local slack = require("slack")

-- The wifi might not be completely ready when the hs.wifi.watcher reacts so
-- wait a bit before setting the status
local wifi_set_status_delay_seconds = 3

local choiceToEmoji = {
    ["Clear status"] = slack.emojis.clear,
    ["Lunch"] = slack.emojis.lunch,
    ["WFH"] = slack.emojis.wfh,
    ["Away"] = slack.emojis.away,
    ["Doctor"] = slack.emojis.doctor,
}

local function updateStatus()
    slack.updateStatus("Working remotely", slack.emojis.wfh)
end

function slack_status.init()
    if type(config.slack_token) ~= "string" then
        return
    end

    ---@diagnostic disable-next-line: unused-local
    hs.wifi.watcher.new(function(_watcher, message, interface)
        local newNetwork = hs.wifi.currentNetwork()

        if hs.fnutils.contains(config.home_wifis, newNetwork) then
            hs.timer.doAfter(wifi_set_status_delay_seconds, updateStatus)
        end
    end):watchingFor({ "SSIDChange" }):start()

    ---@diagnostic disable-next-line: unused-local
    hs.application.watcher.new(function(name, event, app)
        if name == "Slack" and event == hs.application.watcher.launched then
            if hs.fnutils.contains(config.home_wifis, hs.wifi.currentNetwork()) then
                hs.timer.doAfter(wifi_set_status_delay_seconds, updateStatus)
            end
        end
    end)
end

function slack_status.choose()
    local chooser = hs.chooser.new(function(choice)
        if choice then
            local text = choice.text

            if text == "Set online" then
                slack.setPresence("auto")
            elseif text == "Set offline" then
                slack.setPresence("away")
            else
                local message = text == "Clear status" and "" or text
                local emoji = choiceToEmoji[text]

                slack.updateStatus(message, emoji)
            end
        end
    end)

    local choices = {}

    for message, _ in pairs(choiceToEmoji) do
        table.insert(choices, { text = message })
    end

    table.insert(choices, { text = "Set online" })
    table.insert(choices, { text = "Set offline" })

    chooser:placeholderText("Select slack status/presence")
    chooser:choices(choices)
    chooser:show()
end

return slack_status
