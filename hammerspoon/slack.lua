-- Inspired by https://github.com/chrisscott/ZoomSlack
local slack = {}

local config = require("config")
local notify = require("notify")

slack.emojis = {
    away = "🏃",
    doctor = "🏥",
    clear = "",
    lunch = "🍽",
    wfh = "🏡",
    vacation = "🌴",
    sick = "🤒",
}

local function getSlackHeaders()
    return {
        ["Authorization"] = "Bearer " .. config.slack_token,
        ["Content-Type"] = "application/json; charset=utf-8",
    }
end

---@param http_code integer
---@param body table
local function handleSlackResponse(http_code, body)
    local ok, result = pcall(hs.json.decode, body)
    local failed

    if not ok then
        result = body
        failed = true
    else
        failed = http_code ~= 200 or (result and not result.ok)
    end

    if failed then
        print(("Got http error code %d from slack api"):format(http_code))
        notify.send(result and result.error or "No error context", { title = "Setting Slack Status Failed!" })

        return false
    end
end

---@param endpoint string
---@param body table
local function postRequest(endpoint, body)
    hs.http.asyncPost(endpoint, hs.json.encode(body), getSlackHeaders(), handleSlackResponse)
end

---@param text string
---@param emoji string
---@param expiration integer? Expiration of status in seconds
function slack.updateStatus(text, emoji, expiration)
    if type(expiration) == "number" and expiration > 0 then
        expiration = os.time() + expiration
    end

    local body = {
        profile = {
            status_text = text,
            status_emoji = emoji,
            status_expiration = expiration,
        },
    }

    postRequest("https://slack.com/api/users.profile.set", body)
end

---@param presence "auto" | "away"
function slack.setPresence(presence)
    postRequest("https://slack.com/api/users.setPresence", { presence = presence })
end

---@param message string
---@param channel string
function slack.postMessage(message, channel)
    postRequest("https://slack.com/api/chat.postMessage", { text = message, channel = channel })
end

return slack
