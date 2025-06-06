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

    if not ok then
        result = body
    end

    local failed = http_code ~= 200 or (result and not result.ok)

    if failed then
        print(http_code, hs.inspect(body))
        notify.send(result and result.error or "No context", { title = "Setting Slack Status Failed!" })

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

return slack
