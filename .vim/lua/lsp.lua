-- vim: foldenable foldmethod=marker foldlevel=0 fileencoding=utf-8

local map = require('mappings')


-- Globally override lsp border settings
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or 'single'

    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

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

-- Override select lsp methods and diagnostics functionality with lspsaga
if has_lspsaga then
    local function lspsaga_cmd(command)
        return ('<cmd>Lspsaga %s<cr>'):format(command)
    end

    lsp_methods.hover = lspsaga_cmd('hover_doc')
    lsp_methods.code_action = lspsaga_cmd('code_action')
    lsp_methods.rename = lspsaga_cmd('rename')
    lsp_methods.references = lspsaga_cmd('lsp_references')
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

-- Use on_attach to only map the following keys after the language server
-- attaches to the current buffer
local on_attach = function(client, bufnr)
    if client.server_capabilities.completionProvider then
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    end

    local function with_desc(desc)
        return map.with_default_options({ buffer = bufnr, desc = desc })
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
    if vim.fn.maparg('<c-s>', 'n') == '' then
        map.n('<c-s>', lsp_methods.document_symbol, with_desc('Show document symbol'))
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
