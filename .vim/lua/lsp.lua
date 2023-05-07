-- vim: foldenable foldmethod=marker foldlevel=0 fileencoding=utf-8

local map = require('mappings')

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
    local function goto_diagnostic_wrapper(func, severity)
        return function()
            func({ severity = severity })
        end
    end

    local goto_prev_error = goto_diagnostic_wrapper(vim.diagnostic.goto_prev, vim.diagnostic.severity.ERROR)
    local goto_next_error = goto_diagnostic_wrapper(vim.diagnostic.goto_next, vim.diagnostic.severity.ERROR)

    map.set('n', '<localleader>lp', vim.diagnostic.goto_prev, { desc = 'Jump to previous diagnostic' })
    map.set('n', '<localleader>ln', vim.diagnostic.goto_next, { desc = 'Jump to next diagnostic' })
    map.set('n', '<localleader>ep', goto_prev_error, { desc = 'Jump to previous diagnostic error' })
    map.set('n', '<localleader>en', goto_next_error, { desc = 'Jump to next diagnostic error' })
    map.set('n', '<localleader>ll', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })
end

-- We don't want tsserver to format stuff as the default formatting doesn't
-- seem to respect project-local settings for eslint and prettier. Instead,
-- we implicitly rely on null-ls formatting
local lsp_format_wrapper = function()
    vim.lsp.buf.format({ filter = function(client)
        return client.name ~= 'tsserver'
    end})
end

-- Use on_attach to only map the following keys after the language server
-- attaches to the current buffer
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local map_options = map.with_default_options({ buffer = bufnr })

    map.set('n', '<localleader>lc', vim.lsp.buf.declaration, map.merge(map_options, { desc = 'Jump to declaration under cursor' }))
    map.set('n', '<localleader>ld', vim.lsp.buf.definition, map.merge(map_options, { desc = 'Jump to definition under cursor' }))
    map.set('n', 'gd', vim.lsp.buf.definition, map.merge(map_options, { desc = 'Jump to definition under cursor' }))
    map.set('n', '<localleader>lh', vim.lsp.buf.hover, map.merge(map_options, { desc = 'Open lsp float' }))
    map.set('n', '<s-m>', vim.lsp.buf.hover, map.merge(map_options, { desc = 'Open lsp float' }))
    map.set('n', '<localleader>lt', vim.lsp.buf.type_definition, map.merge(map_options, { desc = 'Jump to type definition' }))
    map.set('n', '<localleader>lr', vim.lsp.buf.references, map.merge(map_options, { desc = 'Show lsp references' }))
    map.set('n', '<localleader>lf', lsp_format_wrapper, map.merge(map_options, { desc = 'Format code in buffer' }))
    map.set('v', '<localleader>lf', lsp_format_wrapper, map.merge(map_options, { desc = 'Format code in range' }))

    -- Set up a document symbol mapping if the mapping is not already bound (by e.g. fzf-lua)
    if vim.fn.maparg('<leader>ss', 'n') == '' then
        map.set('n', '<localleader>ss', vim.lsp.buf.document_symbol, map.merge(map_options, { desc = 'Show document symbol' }))
    end

    -- Set up fallback mappings if lspsaga is not installed
    if not has_lspsaga then
        map.set('n', '<localleader>la', vim.lsp.buf.code_action, map.merge(map_options, { desc = 'Open code action menu' }))
        map.set('n', '<localleader>lm', vim.lsp.buf.rename, map.merge(map_options, { desc = 'Rename under cursor' }))
    end

    map.set('n', '<localleader>lig', vim.lsp.buf.implementation, map.merge(map_options, { desc = 'Jump to implementation under cursor' }))
    map.set(
        'n',
        '<localleader>lis',
        open_in_split('split', vim.lsp.buf.implementation),
        map.merge(map_options, { desc = 'Open implementation in a split' })
    )
    map.set(
        'n',
        '<localleader>liv',
        open_in_split('vsplit', vim.lsp.buf.implementation),
        map.merge(map_options, { desc = 'Open implementation in a vertical split' })
    )
    map.set(
        'n',
        '<localleader>lit',
        open_in_split('tab split', vim.lsp.buf.implementation),
        map.merge(map_options, { desc = 'Open implementation in a tab' })
    )
end
-- }}}

-- lsp servers {{{
local lspconfig = require('lspconfig')

if vim.fn.executable('clangd-mp-11') then
    lspconfig.clangd.setup{
        on_attach = on_attach,
        cmd = { 'clangd-mp-11' }
    }
end

if vim.fn.executable('lua-language-server') then
    local runtime_path = vim.split(package.path, ';')
    table.insert(runtime_path, 'lua/?.lua')
    table.insert(runtime_path, 'lua/?/init.lua')

    lspconfig.lua_ls.setup{
        on_attach = on_attach,
        settings = {
            Lua = {
                runtime = {
                    version = 'LuaJIT',
                    path = runtime_path,
                },
                diagnostics = {
                    globals = { 'vim' },
                },
                workspace = {
                    library = {
                        vim.env.VIMRUNTIME,
                        '~/.vim/plugged/neotest',
                        '~/.vim/plugged/plenary.nvim',
                    },
                    maxPreload = 2000,
                    preloadFileSize = 50000,
                    checkThirdParty = false,
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    }
end

-- lspconfig.eslint.setup{ on_attach = on_attach }
lspconfig.tsserver.setup{ on_attach = on_attach }
