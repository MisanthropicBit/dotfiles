-- Inspired by https://github.com/chrisscott/ZoomSlack
local slack = {}

local config = require("config")
local notify = require("notify")

slack.emojis = {
    clear = "",
    lunch = "🍽",
    wfh = "🏠",
}

---@param text string
---@param emoji string
---@param expiration integer
---@param token string
function slack.updateStatus(text, emoji, expiration, token)
    local json = {
        profile = {
            status_text = text,
            status_emoji = emoji,
            status_expiration = expiration
        }
    }

    hs.http.asyncPost(
        "https://slack.com/api/users.profile.set",
        hs.json.encode(json),
        {
            ["Authorization"] = "Bearer " .. token,
            ["Content-type"] = "application/json; charset=utf-8"
        },
        function(http_code, body)
            local result = hs.json.decode(body)
            local failed = (http_code == 200 and result and not result.ok) or (http_code ~= 200)

            if failed then
                notify.send(result and result.error or "No context", { title = "Setting Slack Status Failed!" })
                return false
            end
        end
    )
end

local currentNetwork = hs.wifi.currentNetwork()

if type(config.slack_token) == "string" then
    ---@diagnostic disable-next-line: unused-local
    hs.wifi.watcher.new(function(_watcher, message, interface)
        local newNetwork = hs.wifi.currentNetwork()

        if currentNetwork == nil and newNetwork ~= nil and not config.at_work then
            slack.updateStatus("Working remotely", slack.emojis.wfh, 0, config.slack_token)
        end
    end):watchingFor({ "SSIDChange" }):start()

    ---@diagnostic disable-next-line: unused-local
    hs.application.watcher.new(function(name, event, app)
        if name == "Slack" and event == hs.application.watcher.launched then
            if not config.at_work then
                slack.updateStatus("Working remotely", slack.emojis.wfh, 0, config.slack_token)
            end
        end
    end)
else
    notify.send("Missing slack token in configuration")
end

return slack
