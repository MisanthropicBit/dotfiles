local ansi = require('ansi')
local map = require('mappings')
local lsp_common = require('lsp_common')

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
            symbol_fmt = function(symbol)
                local stripped = ansi.strip_ansi_codes(symbol)
                local icon = lsp_common.kind_icons[stripped]

                if icon ~= nil then
                    local hl = lsp_common.kind_to_hl[stripped]
                    local color

                    -- TODO: Make color lookup into a function in lsp_common
                    if hl ~= nil then
                        color = ansi.highlight_to_rgb_ansi(hl)
                    else
                        -- NOTE: This might cause some color mismatches across the same lsp kinds
                        color = symbol:match(ansi.pattern())
                    end

                    return string.format(
                        '%s%s [%s]%s',
                        color,
                        lsp_common.kind_icons[stripped],
                        stripped,
                        ansi.reset_sequence()
                    )
                else
                    return symbol
                end
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
map.leader('n', 'gf', fzf_lua.git_files, { desc = 'Search files in the current directory that are tracked by git' })
map.leader('n', 'hi', fzf_lua.oldfiles, { desc = 'View file access history' })
