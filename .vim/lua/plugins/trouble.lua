local map = require('mappings')

require('trouble').setup({
    mode = 'document_diagnostics'
})

map.leader('n', 'xx', '<cmd>TroubleToggle document_diagnostics<cr>', { desc = 'Toggle document diagnostics in trouble' })
map.leader('n', 'xl', '<cmd>TroubleToggle loclist<cr>', { desc = 'Toggle loclist diagnostics in trouble' })
