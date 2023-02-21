local map = require('mappings')
local kind_icons = require('lsp_common').kind_icons

local fzf_lua = require('fzf-lua')

fzf_lua.setup{
    winopts = {
        height = 0.75,
    },
    keymap = {
        builtin = {
            ['<c-+>'] = 'toggle-help',
            ['<c-p>'] = 'preview-page-up',
            ['<c-n>'] = 'preview-page-down',
        },
    },
    lsp = {
        git_icons = true,
        symbols = {
            symbol_fmt = function(s)
                return (kind_icons[s] or s)
            end,
        },
    },
    fzf_opts = {
        ['--cycle'] = '',
    },
}

map.leader('n', 'ss', fzf_lua.lsp_document_symbols, { desc = 'LSP document symbols' })
map.leader('n', 'cc', fzf_lua.colorschemes, { desc = 'Pick a colorscheme' })
map.leader('n', 'df', function() fzf_lua.files({ cwd = '~/projects/dotfiles/.vim' }) end, { desc = 'Search dotfiles' })
map.n('<c-p>', fzf_lua.files, { desc = 'Search files in current directory' })
