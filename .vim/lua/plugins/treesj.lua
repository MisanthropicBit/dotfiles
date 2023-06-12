local map = require('mappings')

local treesj = require('treesj')

treesj.setup({
    use_default_keymaps = false,
})

map.n('gm', treesj.toggle, 'Split or join treesitter node')
