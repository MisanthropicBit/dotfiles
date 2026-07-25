---@type config.PluginSpec
return {
    src = "https://www.github.com/MisanthropicBit/winmove.nvim",
    version = "3d553d32a6b1a26bb911ca4e82c32766fd3902e3",
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
