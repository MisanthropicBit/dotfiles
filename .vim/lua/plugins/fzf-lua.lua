local map = require('mappings')
local kind_icons = require('lsp_common').kind_icons

local fzf_lua = require('fzf-lua')

fzf_lua.setup{
    keymap = {
        builtin = {
            ['f?'] = "toggle-help",
        },
    },
    lsp = {
        git_icons = true,
        symbols = {
            symbol_fmt = function(s)
                return '[' .. kind_icons[s] .. ']'
            end,
        },
    },
}

map.leader('n', 'ss', fzf_lua.lsp_document_symbols, { desc = 'LSP document symbols' })
