local map = require("config.map")

require("gx").setup({
    handler_options = {
        search_engine = "https://duckduckgo.com/?q=",
    },
})

map.set({ "n", "x" }, "gx", "<cmd>Browse<cr>")
