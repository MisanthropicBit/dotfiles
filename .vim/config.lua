local goto_preview = require('goto-preview')
local lsp_lines = require('lsp_lines')
local cmp = require('cmp')
require('trouble').setup{}

goto_preview.setup{}
lsp_lines.setup{}

-- Temporarily disable lsp_lines
lsp_lines.toggle()

-- Globally override lsp border settings
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or 'single'

    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

require('nvim-treesitter.configs').setup{
    ensure_installed = { "fish", "javascript", "json", "python", "typescript", "vim" },
    sync_install = false,
    auto_install = true,
    ignore_install = {},
    highlight = {
        enable = true,
        disable = {},
        additional_vim_regex_highlighting = false,
    },
}

vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
        source = "always",
    },
    float = {
        source = "always",
    },
    signs = true,
    underline = true,
    severity_sort = true,
})

-- nvim-cmp
cmp.setup({
    snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
        vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
        { name = 'ultisnips' },
    }, {
        { name = 'buffer' },
    })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
    { name = 'buffer' },
    })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
    { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
    { name = 'path' }
    }, {
    { name = 'cmdline' }
    })
})

-- Completion kinds
-- local M = {}

-- M.icons = {
--     Class = " ",
--     Color = " ",
--     Constant = " ",
--     Constructor = " ",
--     Enum = "了 ",
--     EnumMember = " ",
--     Field = " ",
--     File = " ",
--     Folder = " ",
--     Function = " ",
--     Interface = "ﰮ ",
--     Keyword = " ",
--     Method = "ƒ ",
--     Module = " ",
--     Property = " ",
--     Snippet = "﬌ ",
--     Struct = " ",
--     Text = " ",
--     Unit = " ",
--     Value = " ",
--     Variable = " ",
-- }

-- function M.setup()
--   local kinds = vim.lsp.protocol.CompletionItemKind

--   for i, kind in ipairs(kinds) do
--     kinds[i] = M.icons[kind] or kind
--   end
-- end

-- return M

-- Mappings
local opts = { noremap=true, silent=true }

vim.keymap.set('n', '<localleader>ll', lsp_lines.toggle, opts)
vim.keymap.set('n', 'gp', goto_preview.goto_preview_definition, opts)
vim.keymap.set('n', 'gt', goto_preview.goto_preview_type_definition, opts)
vim.keymap.set('n', 'gi', goto_preview.goto_preview_implementation, opts)
vim.keymap.set('n', 'ge', goto_preview.close_all_win, opts)

-- LSP mappings
vim.keymap.set('n', '<localleader>ln', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<localleader>lp', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', '<localleader>le', vim.diagnostic.open_float, opts)

-- Use on_attach to only map the following keys after the language server
-- attaches to the current buffer
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', '<localleader>lc', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', '<localleader>ld', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', '<localleader>lh', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', '<localleader>li', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<localleader>ls', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<localleader>lt', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<localleader>lm', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<localleader>la', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', '<localleader>lr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<localleader>lf', vim.lsp.buf.formatting, bufopts)
end

-- nvim's builtin lsp
require('lspconfig').eslint.setup{ on_attach = on_attach }
require('lspconfig').tsserver.setup{ on_attach = on_attach }
