return {
    "MisanthropicBit/winmove.nvim",
    config = function()
        local winmove = require("winmove")

        winmove.configure({
            modes = {
                move = {
                    at_edge = {
                        horizontal = winmove.AtEdge.MoveToTab,
                        vertical = winmove.AtEdge.Wrap,
                    },
                },
                swap = {
                    at_edge = {
                        horizontal = winmove.AtEdge.MoveToTab,
                        vertical = winmove.AtEdge.Wrap,
                    },
                },
            },
        })
    end
}
