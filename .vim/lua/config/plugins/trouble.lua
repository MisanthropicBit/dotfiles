local map = require('config.map')

require('trouble').setup({
    mode = 'document_diagnostics'
})

map.leader('n', 'xx', '<cmd>TroubleToggle document_diagnostics<cr>', 'Toggle document diagnostics in trouble')
map.leader('n', 'xl', '<cmd>TroubleToggle loclist<cr>', 'Toggle loclist diagnostics in trouble')
