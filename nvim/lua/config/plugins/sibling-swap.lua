return {
    "Wansmer/sibling-swap.nvim", 
    config = function()
        local map = require("config.map")
        local sibling_swap = require("sibling-swap")

        sibling_swap.setup({
            use_default_keymaps = false,
        })

        map.n("<c-9>", sibling_swap.swap_with_left)
        map.n("<c-0>", sibling_swap.swap_with_right)
    end,
}
