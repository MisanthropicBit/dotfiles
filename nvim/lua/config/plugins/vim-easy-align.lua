return {
    "junegunn/vim-easy-align", 
    config = function()
        local map = require("config.map")

        map.set({ "n", "x" }, "ga", "<Plug>(EasyAlign)", { noremap = false })
    end,
}
