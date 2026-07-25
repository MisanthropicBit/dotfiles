---@type config.PluginSpec
return {
    src = "https://www.github.com/junegunn/vim-easy-align",
    version = "9815a55dbcd817784458df7a18acacc6f82b1241",
    data = {
        config = function()
            local map = require("config.map")

            map.set({ "n", "x" }, "ga", "<Plug>(EasyAlign)", { noremap = false })
        end,
    },
}
