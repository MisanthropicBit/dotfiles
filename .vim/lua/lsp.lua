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
local function fzf_lua_lsp_jump_selector(locations)
    local fzf_items = vim.tbl_map(function(item)
        return ('%s:%d:%d'):format(item.filename, item.lnum, item.col)
    end, locations)

    require('fzf-lua').fzf_exec(
        fzf_items,
        {
            prompt = 'Jump to?> ',
            previewer = 'builtin'
        }
    )
end

---Jump to an lsp result in a split window or select between results if there
---is more than one
---@param lsp_method string
---@param split_cmd string
---@param selector 'fzf' | 'quickfix'
---@return function
local function lsp_request_jump(lsp_method, split_cmd, selector)
    return function()
        local params = vim.lsp.util.make_position_params(0)

        -- TODO: Use buf_request_sync instead?
        vim.lsp.buf_request_all(0, lsp_method, params, function(results)
            local clients = vim.tbl_keys(results)

            if #clients == 0 then
                return
            elseif #clients == 1 then
                local client = vim.lsp.get_client_by_id(clients[1])

                vim.cmd(split_cmd)
                vim.lsp.util.jump_to_location(
                    results[client.id].result[1],
                    client.offset_encoding,
                    false
                )
                vim.cmd('normal zz')
            else
                local locations = {}

                for client_id, result in pairs(results) do
                    local client = vim.lsp.get_client_by_id(client_id)
                    local items = vim.lsp.util.locations_to_items(result.result, client.offset_encoding)

                    vim.list_extend(locations, items)
                end

                if selector == 'fzf' then
                    fzf_lua_lsp_jump_selector(locations)
                else
                    vim.fn.setqflist({}, ' ', { items = locations })
                    vim.cmd('copen')
                end
            end
        end)
    end
end

---@diagnostic disable-next-line: unused-local
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
---@diagnostic disable-next-line: unused-local
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local map_options = map.with_default_options({ buffer = bufnr })

    map.leader('n', 'lc', vim.lsp.buf.declaration, map.merge(map_options, { desc = 'Jump to declaration under cursor' }))
    map.set('n', 'gd', vim.lsp.buf.definition, map.merge(map_options, { desc = 'Jump to definition under cursor' }))
    map.leader('n', 'lt', vim.lsp.buf.type_definition, map.merge(map_options, { desc = 'Jump to type definition' }))
    map.leader('n', 'lf', lsp_format_wrapper, map.merge(map_options, { desc = 'Format code in buffer' }))
    map.leader('v', 'lf', lsp_format_wrapper, map.merge(map_options, { desc = 'Format code in range' }))

    -- Set up a document symbol mapping if the mapping is not already bound (by e.g. fzf-lua)
    if vim.fn.maparg('<leader>ss', 'n') == '' then
        map.set('n', '<localleader>ss', vim.lsp.buf.document_symbol, map.merge(map_options, { desc = 'Show document symbol' }))
    end

    -- Set up fallback mappings if lspsaga is not installed
    if not has_lspsaga then
        map.set('n', '<s-m>', vim.lsp.buf.hover, map.merge(map_options, { desc = 'Open lsp float' }))
        map.leader('n', 'la', vim.lsp.buf.code_action, { desc = 'Open code action menu' })
        map.leader('v', 'la', vim.lsp.buf.code_action, { desc = 'Open code action menu in visual mode' })
        map.leader('n', 'la', vim.lsp.buf.code_action, map.merge(map_options, { desc = 'Open code action menu' }))
        map.leader('n', 'lm', vim.lsp.buf.rename, map.merge(map_options, { desc = 'Rename under cursor' }))
        map.leader('n', 'lr', vim.lsp.buf.references, map.merge(map_options, { desc = 'Show lsp references' }))
    end

    local lsp_method = 'textDocument/definition'
    local selector = 'quickfix'

    -- Use the good old ALE mappings :)
    map.leader('n', 'as', lsp_request_jump(lsp_method, 'split', selector), map.merge(map_options, { desc = 'Jump to definition in a horizontal split' }))
    map.leader('n', 'av', lsp_request_jump(lsp_method, 'vsplit', selector), map.merge(map_options, { desc = 'Jump to definition in a vertical split' }))
    map.set('n', 'at', lsp_request_jump(lsp_method, 'tabe', selector), map.merge(map_options, { desc = 'Jump to definition in a tab' }))
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
