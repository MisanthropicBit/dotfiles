-- Inspired by https://github.com/chrisscott/ZoomSlack
local slack = {}

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

return slack
