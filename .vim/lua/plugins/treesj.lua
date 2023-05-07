local map = require('mappings')

local treesj = require('treesj')

treesj.setup({
    use_default_keymaps = false,
})

-- TODO: This will collide with the ts-node-action 'gn' mapping
map.n('gm', treesj.toggle, { desc = 'Split or join treesitter node' })
