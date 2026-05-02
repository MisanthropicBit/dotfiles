return {
    src = "https://www.github.com/MisanthropicBit/winmove.nvim",
    data = {
        config = function(winmove)
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
        end,
    },
}
