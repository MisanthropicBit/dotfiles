local map = require('mappings')
local lsp_common = require('lsp_common')
local lspsaga = require('lspsaga')

lspsaga.setup({
    max_preview_lines = 20,
    finder = {
        keys = {
            split = 's',
            vsplit = 'v',
        },
    },
    diagnostic = {
        twice_into = true,
    },
    definition = {
        split = '<c-w>s',
        vsplit = '<c-w>v',
        tabe = '<c-w>t',
    },
    symbol_in_winbar = {
        separator = '  ',
    },
    lightbulb = {
        sign = false,
    },
    beacon = {
        enable = false,
    },
    ui = {
        kind = {
            ['Method'] = {
                lsp_common.kind_icons['Method'],
                lsp_common.kind_to_hl['Method'],
            },
        },
    },
})

map.leader('n', 'ly', '<cmd>Lspsaga outline<cr>', 'Toggle outline of semantic elements')
map.leader('n', 'ls', '<cmd>Lspsaga lsp_finder<cr>', 'Trigger the lspsaga finder')
