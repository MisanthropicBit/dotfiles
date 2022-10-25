-- vim: foldenable foldmethod=marker foldlevel=0 fileencoding=utf-8

require('plugins')
require('lsp')

local map_options = require('mappings').map_options

-- Text yank highlight {{{
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})
-- }}}

-- Shortcuts for editing the config.lua file {{{
local cur_path = vim.fn.expand('%:p')

vim.keymap.set('n', '<localleader>cs', string.format('<cmd>sp %s<cr>', cur_path), map_options)
vim.keymap.set('n', '<localleader>cv', string.format('<cmd>vs %s<cr>', cur_path), map_options)
vim.keymap.set('n', '<localleader>ct', string.format('<cmd>tabe %s<cr>', cur_path), map_options)
-- }}}
