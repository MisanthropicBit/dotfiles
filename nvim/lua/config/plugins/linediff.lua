return {
    "AndrewRadev/linediff.vim",
    config = function()
        local map = require("config.map")

        -- vim.cmd([[nmap <silent> gl :set opfunc=<Plug>(linediff-operator)<cr>g@]])

        map.v(
            "gl",
            ":Linediff<cr>",
            { noremap = false, desc = "Set a line diff for the current visual range" }
        )
    end,
}
