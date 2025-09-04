return {
    "kylechui/nvim-surround",
    config = function()
        local surround = require("nvim-surround")
        local defaults = require("nvim-surround.config").default_opts
        local map = require("config.map")

        surround.setup({
            surrounds = {
                ["8"] = defaults.surrounds[")"],
                ["9"] = defaults.surrounds["{"],
            },
        })

        map.n("g'", "<cmd>normal ysiw'<cr>")
        -- map.n("g´", "<cmd>normal ysiw`<cr>>")
        map.n("g0", "<cmd>normal ysiw\"<cr>")
        map.n("g8", "<cmd>normal ysiw)<cr>")
        map.n("g9", "<cmd>normal ysiw]<cr>")
    end,
}
