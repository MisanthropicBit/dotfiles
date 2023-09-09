local map = require('config.map')

require('nvim-treesitter.configs').setup({
    playground = {
        enable = true
    }
})

-- TODO: Update with neovim 0.9.0
map.leader(
    'n',
    'sg',
    '<cmd>TSHighlightCapturesUnderCursor<cr>',
    'Highlight treesitter or syntax group under cursor'
)
