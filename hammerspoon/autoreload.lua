local autoreload = {}

local notify = require("notify")

---@param files string[]
local function reloadConfig(files)
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            hs.reload()
            break
        end
    end
end

function autoreload.init()
    hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
    notify.send("Config loaded")
end

return autoreload
