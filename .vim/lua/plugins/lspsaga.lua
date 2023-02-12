local map = require('mappings')

local has_lspsaga, lspsaga = pcall(require, 'lspsaga')

if has_lspsaga then
    lspsaga.setup{
        max_preview_lines = 20,
        finder = {
            split = 's',
            vsplit = 'v',
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
    }

    local lspsaga_diagnostic = require('lspsaga.diagnostic')
    local error_severity = vim.diagnostic.severity.ERROR

    local goto_prev_error = function()
        lspsaga_diagnostic:goto_prev({ severity = error_severity })
    end

    local goto_next_error = function()
        lspsaga_diagnostic:goto_next({ severity = error_severity })
    end

    -- Overwrite lsp defaults with lspsaga
    map.leader('n', 'll', '<cmd>Lspsaga show_line_diagnostics<cr>', { desc = 'Show line diagnostics' })
    map.leader('n', 'la', '<cmd>Lspsaga code_action<cr>', { desc = 'Open code action menu' })
    map.leader('v', 'la', '<cmd>Lspsaga code_action<cr>', { desc = 'Open code action menu in visual mode' })
    map.leader('n', 'lp', '<cmd>Lspsaga diagnostic_jump_prev<cr>', { desc = 'Jump to previous diagnostic' })
    map.leader('n', 'ln', '<cmd>Lspsaga diagnostic_jump_next<cr>', { desc = 'Jump to next diagnostic' })
    map.leader('n', 'ep', goto_prev_error, { desc = 'Jump to previous diagnostic error' })
    map.leader('n', 'en', goto_next_error, { desc = 'Jump to next diagnostic error' })
    map.leader('n', 'lm', '<cmd>Lspsaga rename<cr>', { desc = 'Rename under cursor' })
    map.leader('n', 'ly', '<cmd>Lspsaga outline<cr>', { desc = 'Toggle outline of semantic elements' })
    map.leader('n', 'ls', '<cmd>Lspsaga lsp_finder<cr>', { desc = 'Trigger the lspsaga finder' })
end
