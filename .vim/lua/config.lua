-- vim: foldenable foldmethod=marker foldlevel=0 fileencoding=utf-8

require('plugins')
require('lsp')
require('notify')

pcall(require, 'private_plugins')

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
