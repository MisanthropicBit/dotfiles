return {
    "numToStr/Comment.nvim",
    config = function()
        local map = require("config.map")

        map.n("ycc", "yygccp", {
            remap = true,
            desc = "Copy line below and comment original line"
        })
    end,
}
