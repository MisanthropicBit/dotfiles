local map = require('mappings')

local nvim_treesitter_playground = require('nvim-treesitter-playground')

map.leader(
    'n',
    'sg',
    '<cmd>TSHighlightCapturesUnderCursor<cr>',
    { desc = 'Highlight treesitter or syntax group under cursor' }
)
