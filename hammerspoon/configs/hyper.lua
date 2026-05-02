local actions = require("hyper.actions")
local autolayout = require("autolayout")
local config = require("config")
local slack_status = require("slack_status")
local ClipboardTool = require("ClipboardTool")

local default_window_transition_speed = 0.3

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
            -- {
            --     key = "j",
            --     action = function()
            --         local window = hs.window.focusedWindow()
            --
            --         if window then
            --             window:moveToUnit(
            --                 hs.geometry(0, 0, 0.5, 1),
            --                 config.window_transition_speed or default_window_transition_speed
            --             )
            --         end
            --     end,
            -- },
            -- {
            --     key = "k",
            --     action = function()
            --         local window = hs.window.focusedWindow()
            --
            --         if window then
            --             window:moveToUnit(
            --                 hs.geometry(0.5, 0, 0.5, 1),
            --                 config.window_transition_speed or default_window_transition_speed
            --             )
            --         end
            --     end,
            -- },
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
                key = "e",
                action = function()
                    ClipboardTool:toggleClipboard()
                end,
            },
            {
                key = "8",
                action = actions.keyStroke("8", { "alt", "shift" }),
                options = { preventRetrigger = true },
            },
            {
                key = "9",
                action = actions.keyStroke("9", { "alt", "shift" }),
                options = { preventRetrigger = true },
            },
            {
                key = "'",
                action = actions.keyStroke("'", { "alt" }),
            },
            {
                key = "¨",
                action = actions.keyStroke("¨", { "alt" }),
            },
            {
                key = "delete",
                action = actions.keyStroke("delete", { "alt" }),
            },
            {
                key = "j",
                action = actions.keyStroke("left", { "alt" }),
            },
            {
                key = "k",
                action = actions.keyStroke("right", { "alt" }),
            },
            {
                key = "ø",
                -- Presses '|'
                action = actions.keyStroke("i", { "alt" }),
            },
        },
    },
}
