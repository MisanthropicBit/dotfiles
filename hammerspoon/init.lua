local function reloadConfig(files)
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            hs.reload()
            break
        end
    end
end

require("hyper")

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

hs.notify
    .new({
        title = "Hammerspoon",
        informativeText = "Config loaded",
        withdrawAfter = 2,
    })
    :send()
