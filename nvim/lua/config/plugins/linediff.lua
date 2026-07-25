---@type config.PluginSpec
return {
    src = "https://www.github.com/AndrewRadev/linediff.vim",
    version = "29fa617fc10307a1e0ae82a8761114e465d17b06",
    data = {
        config = function()
            local map = require("config.map")

            -- vim.cmd([[nmap <silent> gl :set opfunc=<Plug>(linediff-operator)<cr>g@]])

            map.v("gl", ":Linediff<cr>", { noremap = false, desc = "Set a line diff for the current visual range" })
        end,
    },
}
