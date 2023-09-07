local map = require("config.map")

local sibling_swap = require("sibling-swap")

sibling_swap.setup({
    use_default_keymaps = false,
})

map.leader("n", "sh", sibling_swap.swap_with_left)
map.leader("n", "sl", sibling_swap.swap_with_right)
