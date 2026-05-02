return {
    src = "https://www.github.com/Wansmer/sibling-swap.nvim",
    data = {
        config = function(sibling_swap)
            local map = require("config.map")

            sibling_swap.setup({
                use_default_keymaps = false,
            })

            map.n("<c-9>", sibling_swap.swap_with_left)
            map.n("<c-0>", sibling_swap.swap_with_right)
        end,
    },
}
