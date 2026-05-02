return {
    src = "https://www.github.com/junegunn/vim-easy-align",
    data = {
        config = function()
            local map = require("config.map")

            map.set({ "n", "x" }, "ga", "<Plug>(EasyAlign)", { noremap = false })
        end,
    },
}
