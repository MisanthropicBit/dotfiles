local notify = {}

---@class NotifyOptions
---@field title string?
---@field withdrawAfter integer?

---@param message string
---@param options NotifyOptions?
function notify.send(message, options)
    local _options = options or {}

    hs.notify
        .new({
            title = _options.title or "Config",
            informativeText = message,
            withdrawAfter = _options.withdrawAfter or 2,
        })
        :send()
end

---@param message string
function notify.error(message)
    notify.send(message, { title = "Config error" })
end

return notify
