local lspsaga = require('lspsaga')

local map = require('config.map')
local lsp_utils = require('config.lsp.utils')

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
                lsp_utils.kind_icons['Method'],
                lsp_utils.kind_to_hl['Method'],
            },
        },
    },
})

map.leader('n', 'ly', '<cmd>Lspsaga outline<cr>', 'Toggle outline of semantic elements')
map.leader('n', 'ls', '<cmd>Lspsaga finder<cr>', 'Trigger the lspsaga finder')
