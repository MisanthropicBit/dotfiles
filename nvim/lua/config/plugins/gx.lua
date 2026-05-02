return {
    src = "https://www.github.com/chrishrb/gx.nvim",
    data = {
        config = function(gx)
            local map = require("config.map")

            gx.setup({
                handler_options = {
                    search_engine = "https://duckduckgo.com/?q=",
                },
            })

            map.set({ "n", "x" }, "gx", "<cmd>Browse<cr>")
        end,
    },
}
