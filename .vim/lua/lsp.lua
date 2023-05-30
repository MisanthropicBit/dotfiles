-- vim: foldenable foldmethod=marker foldlevel=0 fileencoding=utf-8

local icons = require('icons')
local map = require('mappings')

for type, icon in pairs(icons.diagnostics) do
    local hl = 'DiagnosticSign' .. type:sub(1, 1):upper() .. type:sub(2)
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Globally override lsp border settings
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or 'single'

    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- vim diagnostics config
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

-- Mappings {{{
---@diagnostic disable-next-line: unused-local
local has_lspsaga, lspsaga = pcall(require, 'lspsaga')

-- We don't want tsserver to format stuff as the default formatting doesn't
-- seem to respect project-local settings for eslint and prettier. Instead,
-- we implicitly rely on null-ls formatting
local lsp_format_wrapper = function()
    vim.lsp.buf.format({ filter = function(client)
        return client.name ~= 'tsserver'
    end})
end

---Create a function that will jump to a diagnostic of a certain severity
---@param func function
---@param severity integer
---@return function
local function goto_diagnostic_wrapper(func, severity)
    return function()
        func({ severity = severity })
    end
end

-- LSP methods for the right-hand side of lsp mappings
local lsp_methods = {
    definition = vim.lsp.buf.definition,
    declaration = vim.lsp.buf.declaration,
    hover = vim.lsp.buf.hover,
    type_definition = vim.lsp.buf.type_definition,
    formatting = lsp_format_wrapper,
    signature_help = vim.lsp.buf.signature_help,
    document_symbol = vim.lsp.buf.document_symbol,
    code_action = vim.lsp.buf.code_action,
    rename = vim.lsp.buf.rename,
    references = vim.lsp.buf.references,
}

local error_severity = vim.diagnostic.severity.ERROR

-- Diagnostic methods for the right-hand side of lsp mappings
local diagnostics_methods = {
    goto_prev = vim.diagnostic.goto_prev,
    goto_next = vim.diagnostic.goto_next,
    goto_prev_error = goto_diagnostic_wrapper(vim.diagnostic.goto_prev, error_severity),
    goto_next_error = goto_diagnostic_wrapper(vim.diagnostic.goto_next, error_severity),
    open_float = vim.diagnostic.open_float,
}

-- Override select lsp methods and diagnostics functionality with lspsaga
if has_lspsaga then
    local function lspsaga_cmd(command)
        return ('<cmd>Lspsaga %s<cr>'):format(command)
    end

    lsp_methods.hover = lspsaga_cmd('hover_doc')
    lsp_methods.code_action = lspsaga_cmd('code_action')
    lsp_methods.rename = lspsaga_cmd('rename')
    lsp_methods.references = lspsaga_cmd('lsp_references')

    local lspsaga_diagnostic = require('lspsaga.diagnostic')

    local lspsaga_goto_prev_error = function()
        lspsaga_diagnostic:goto_prev({ severity = error_severity })
    end

    local lspsaga_goto_next_error = function()
        lspsaga_diagnostic:goto_next({ severity = error_severity })
    end

    diagnostics_methods.goto_prev = lspsaga_cmd('diagnostic_jump_prev')
    diagnostics_methods.goto_next = lspsaga_cmd('diagnostic_jump_next')
    diagnostics_methods.goto_prev_error = lspsaga_goto_prev_error
    diagnostics_methods.goto_next_error = lspsaga_goto_next_error
    diagnostics_methods.open_float = lspsaga_cmd('show_line_diagnostics ++unfocus')
end

---Use fzf-lua as a lsp result selector in case of multiple results
---@param locations any
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

                local has_fzf_lua, _ = pcall(require, 'fzf-lua')

                if selector == 'fzf' and has_fzf_lua then
                    fzf_lua_lsp_jump_selector(locations)
                else
                    vim.fn.setqflist({}, ' ', { items = locations })
                    vim.cmd('copen')
                end
            end
        end)
    end
end

-- Diagnostic mappings
map.leader('n', 'lp', diagnostics_methods.goto_prev, { desc = 'Jump to previous diagnostic' })
map.leader('n', 'ln', diagnostics_methods.goto_next, { desc = 'Jump to next diagnostic' })
map.leader('n', 'ep', diagnostics_methods.goto_prev_error, { desc = 'Jump to previous diagnostic error' })
map.leader('n', 'en', diagnostics_methods.goto_next_error, { desc = 'Jump to next diagnostic error' })
map.leader('n', 'll', diagnostics_methods.open_float, { desc = 'Open diagnostic float' })

-- Use on_attach to only map the following keys after the language server
-- attaches to the current buffer
local on_attach = function(client, bufnr)
    if client.server_capabilities.completionProvider then
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    end

    local function with_desc(desc)
        return map.merge(map.with_default_options({ buffer = bufnr }), { desc = desc })
    end

    -- We don't guard against server capabilities because we want neovim to
    -- inform us if the lsp server doesn't support a method
    map.n('gd', lsp_methods.definition, with_desc('Jump to definition under cursor'))
    map.n('<s-m>', lsp_methods.hover, with_desc('Open lsp float'))
    map.leader('n', 'lc', lsp_methods.declaration, with_desc('Jump to declaration under cursor'))
    map.leader('n', 'lt', lsp_methods.type_definition, with_desc('Jump to type definition'))
    map.leader('n', 'lh', lsp_methods.signature_help, with_desc('Lsp signature help'))
    map.leader('n', 'lm', lsp_methods.rename, with_desc('Rename under cursor'))
    map.leader('n', 'lr', lsp_methods.references, with_desc('Show lsp references'))
    map.leader({ 'n', 'v' }, 'lf', lsp_methods.formatting, with_desc('Format code in a buffer or in a range'))
    map.leader({ 'n', 'v' }, 'la', lsp_methods.code_action, with_desc('Open code action menu at cursor or in a range'))

    -- Set up a document symbol mapping if the mapping is not already bound (by e.g. fzf-lua)
    if vim.fn.maparg('<leader>ss', 'n') == '' then
        map.leader('n', 'ss', lsp_methods.document_symbol, with_desc('Show document symbol'))
    end

    local lsp_method = 'textDocument/definition'
    local selector = 'quickfix'

    -- Use the good old ALE mappings :)
    map.leader('n', 'as', lsp_request_jump(lsp_method, 'split', selector), with_desc('Jump to definition in a horizontal split'))
    map.leader('n', 'av', lsp_request_jump(lsp_method, 'vsplit', selector), with_desc('Jump to definition in a vertical split'))
    map.leader('n', 'at', lsp_request_jump(lsp_method, 'tabe', selector), with_desc('Jump to definition in a tab'))
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

lspconfig.tsserver.setup{ on_attach = on_attach }
