---@type config.PluginSpec
return {
    src = "https://www.github.com/chrishrb/gx.nvim",
    version = "ba9c408fc0130fc4548760c3933a81b58fc50de8",
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
