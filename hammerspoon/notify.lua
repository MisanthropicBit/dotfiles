local notify = {}

---@param message string
---@param options table<string, any>?
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

return notify
