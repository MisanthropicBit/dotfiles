local actions = require("hyper.actions")
local autolayout = require("autolayout")
local config = require("config")
local slack_status = require("slack_status")

local default_window_transition_speed = 0.3

--- See: https://stackoverflow.com/a/40987183
---@param modifiers string[]
---@param character string
local function fastKeyStroke(modifiers, character)
    local event = require("hs.eventtap").event

    event.newKeyEvent(modifiers, string.lower(character), true):post()
    event.newKeyEvent(modifiers, string.lower(character), false):post()
end

return {
    {
        hyperKey = "F18",
        remap = {
            source = 0x700000039,
            sourceName = "Capslock",
            target = 0x70000006D,
            targetName = "F18",
        },
        keymaps = {
            {
                key = "i",
                action = actions.launch("iTerm"),
            },
            {
                key = "b",
                action = actions.launch("Brave Browser"),
            },
            {
                key = "c",
                action = actions.launch("Hammerspoon"),
            },
            {
                key = "r",
                action = hs.reload,
            },
            {
                key = "a",
                action = actions.launch("Activity Monitor"),
            },
            {
                key = "f",
                action = actions.launch("com.apple.finder", "bundleId"),
            },
            {
                key = "q",
                action = hs.caffeinate.lockScreen,
            },
            {
                key = "p",
                action = actions.launch("1Password"),
            },
            {
                key = "v",
                action = actions.launch("Preview"),
            },
            {
                key = "s",
                action = actions.launch("Slack"),
            },
            {
                key = "d",
                action = actions.launch("DataGrip"),
            },
            {
                key = "n",
                action = actions.launch("Notion"),
            },
            {
                key = "y",
                action = function()
                    autolayout.apply(config.at_work() and "work" or "wfh", {
                        skipCondition = true,
                    })
                end,
            },
            {
                key = "h",
                action = function()
                    local window = hs.window.focusedWindow()

                    if window then
                        window:moveOneScreenWest(
                            false,
                            true,
                            config.window_transition_speed or default_window_transition_speed
                        )
                    end
                end,
            },
            {
                key = "l",
                action = function()
                    local window = hs.window.focusedWindow()

                    if window then
                        window:moveOneScreenEast(
                            false,
                            true,
                            config.window_transition_speed or default_window_transition_speed
                        )
                    end
                end,
            },
            {
                key = "j",
                action = function()
                    local window = hs.window.focusedWindow()

                    if window then
                        window:moveToUnit(
                            hs.geometry(0, 0, 0.5, 1),
                            config.window_transition_speed or default_window_transition_speed
                        )
                    end
                end,
            },
            {
                key = "k",
                action = function()
                    local window = hs.window.focusedWindow()

                    if window then
                        window:moveToUnit(
                            hs.geometry(0.5, 0, 0.5, 1),
                            config.window_transition_speed or default_window_transition_speed
                        )
                    end
                end,
            },
            {
                key = "u",
                action = slack_status.choose,
            },
            {
                key = "m",
                action = function()
                    local window = hs.window.focusedWindow()

                    if window then
                        window:maximize()
                    end
                end,
            },
            {
                key = "o",
                action = actions.launch("Docker Desktop"),
            },
            {
                key = "8",
                action = function()
                    hs.eventtap.keyStroke({ "alt", "shift" }, "8")
                end,
                options = { preventRetrigger = true },
            },
            {
                key = "9",
                action = function()
                    hs.eventtap.keyStroke({ "alt" }, "8")
                end,
                options = { preventRetrigger = true },
            },
            {
                key = "'",
                action = function()
                    fastKeyStroke({ "alt" }, "'")
                end,
                options = { preventRetrigger = true }
            },
        },
    },
}
