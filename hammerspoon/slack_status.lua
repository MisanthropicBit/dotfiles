local slack_status = {}

local config = require("config")
local slack = require("slack")

-- The wifi might not be completely ready when the hs.wifi.watcher reacts so
-- wait a bit before setting the status
local wifi_set_status_delay_seconds = 8

local choiceToEmoji = {
    ["Clear status"] = { slack.emojis.clear, false },
    ["Lunch"] = { slack.emojis.lunch, true },
    ["WFH"] = { slack.emojis.wfh, true },
    ["Away"] = { slack.emojis.away, false },
    ["Doctor"] = { slack.emojis.doctor, false },
}

local function updateStatus()
    local message, emoji = "", slack.emojis.clear

    if not config.at_work() then
        message, emoji = "WFH", slack.emojis.wfh
    end

    hs.timer.doAfter(wifi_set_status_delay_seconds, function()
        slack.updateStatus(message, emoji)
        slack.setPresence("auto")
    end)
end

function slack_status.init()
    if type(config.slack_token) ~= "string" then
        return
    end

    ---@diagnostic disable-next-line: unused-local
    local watcher = hs.wifi.watcher.new(function(_watcher, message, interface)
        local newNetwork = hs.wifi.currentNetwork()

        if not newNetwork then
            return
        end

        updateStatus()
    end)

    watcher:watchingFor({ "SSIDChange" })
    watcher:start()

    ---@diagnostic disable-next-line: unused-local
    hs.application.watcher.new(function(name, event, app)
        if name == "Slack" and event == hs.application.watcher.launched then
            updateStatus()
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
                slack.updateStatus("", slack.emojis.clear)
            else
                local message = text == "Clear status" and "" or text
                local emoji, online = choiceToEmoji[text][1], choiceToEmoji[text][2]

                slack.updateStatus(message, emoji)
                slack.setPresence(online and "auto" or "away")
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
