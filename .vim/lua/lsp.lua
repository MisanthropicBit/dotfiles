-- vim: foldenable foldmethod=marker foldlevel=0 fileencoding=utf-8

local map_options = require('mappings').map_options

local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }

for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Globally override lsp border settings {{{
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or 'single'

    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
-- }}}

-- vim diagnostics config {{{
vim.diagnostic.config({
    virtual_text = {
        prefix = '●',
        source = 'always',
    },
    float = {
        source = 'always',
    },
    signs = true,
    underline = true,
    severity_sort = true,
})
-- }}}

-- Mappings {{{
local function open_in_split(split_cmd, cmd)
  return function()
    vim.cmd(split_cmd)
    cmd()
  end
end

local has_lspsaga, lspsaga = pcall(require, 'lspsaga')

if not has_lspsaga then
    vim.keymap.set('n', '<localleader>ln', vim.diagnostic.goto_next, map_options)
    vim.keymap.set('n', '<localleader>lp', vim.diagnostic.goto_prev, map_options)
    vim.keymap.set('n', '<localleader>le', vim.diagnostic.open_float, map_options)
end

-- Use on_attach to only map the following keys after the language server
-- attaches to the current buffer
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local map_options = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', '<localleader>lc', vim.lsp.buf.declaration, map_options)
    vim.keymap.set('n', '<localleader>ld', vim.lsp.buf.definition, map_options)
    vim.keymap.set('n', '<localleader>lh', vim.lsp.buf.hover, map_options)
    vim.keymap.set('n', '<localleader>ls', vim.lsp.buf.signature_help, map_options)
    vim.keymap.set('n', '<localleader>lt', vim.lsp.buf.type_definition, map_options)
    vim.keymap.set('n', '<localleader>lr', vim.lsp.buf.references, map_options)
    vim.keymap.set('n', '<localleader>lf', vim.lsp.buf.formatting, map_options)

    if not has_lspsaga then
        vim.keymap.set('n', '<localleader>la', vim.lsp.buf.code_action, map_options)
        vim.keymap.set('n', '<localleader>lm', vim.lsp.buf.rename, map_options)
    end

    vim.keymap.set('n', '<localleader>lig', vim.lsp.buf.implementation, map_options)
    vim.keymap.set(
        'n',
        '<localleader>lis',
        open_in_split('split', vim.lsp.buf.implementation),
        map_options
    )
    vim.keymap.set(
        'n',
        '<localleader>liv',
        open_in_split('vsplit', vim.lsp.buf.implementation),
        map_options
    )
    vim.keymap.set(
        'n',
        '<localleader>lit',
        open_in_split('tab split', vim.lsp.buf.implementation),
        map_options
    )
end
-- }}}

-- lsp servers {{{
local lspconfig = require('lspconfig')

lspconfig.eslint.setup{ on_attach = on_attach }
lspconfig.tsserver.setup{ on_attach = on_attach }

-- if vim.g.loaded_fzf then
    local fuzzy_lsp_symbols = require('fuzzy_lsp_symbols')

    vim.lsp.handlers['textDocument/documentSymbol'] = fuzzy_lsp_symbols.fuzzy_symbol_handler
-- end
-- }}}
