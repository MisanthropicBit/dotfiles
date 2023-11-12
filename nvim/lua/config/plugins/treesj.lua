local treesj = require("treesj")

local map = require("config.map")

treesj.setup({
    use_default_keymaps = false,
    max_join_length = 9999,
})

map.n("gm", treesj.toggle, "Split or join treesitter node")
