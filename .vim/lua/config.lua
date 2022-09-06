local goto_preview = require('goto-preview')
local lsp_lines = require('lsp_lines')
local cmp = require('cmp')
require('trouble').setup{}

goto_preview.setup{}
lsp_lines.setup{}

-- Temporarily disable lsp_lines
lsp_lines.toggle()


-- bufferline.nvim

local function diagnostics_indicator(count, leve, diagnostics_dict, context)
  local s = ' '

  for e, n in pairs(diagnostics_dict) do
    local sym = e == 'error' and ' ' or (e == 'warning' and ' ' or ' ')

    s = s .. n .. sym
  end
  return s
end

require('bufferline').setup{
  options = {
    mode = 'tabs',
    diagnostics = 'nvim_lsp',
    color_icons = true,
    diagnostics_indicator = diagnostics_indicator,
  }
}

vim.keymap.set('n', 'gb', '<cmd>BufferLinePick', { silent = true })

-- Globally override lsp border settings
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or 'single'

    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

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

-- Completion kinds
local kind_icons = {
    Class = ' ',
    Color = ' ',
    Constant = ' ',
    Constructor = ' ',
    Enum = '了 ',
    EnumMember = ' ',
    Field = ' ',
    File = ' ',
    Folder = ' ',
    Function = ' ',
    Interface = 'ﰮ ',
    Keyword = ' ',
    Method = 'ƒ ',
    Module = ' ',
    Property = ' ',
    Snippet = '﬌ ',
    Struct = ' ',
    Text = ' ',
    Unit = ' ',
    Value = ' ',
    Variable = ' ',
}

cmp.setup({
    snippet = {
    expand = function(args)
        vim.fn['UltiSnips#Anon'](args.body) -- For `ultisnips` users.
    end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<c-b>'] = cmp.mapping.scroll_docs(-4),
        ['<c-f>'] = cmp.mapping.scroll_docs(4),
        ['<c-n>'] = cmp.mapping.complete(),
        ['<c-e>'] = cmp.mapping.abort(),
        ['<c-y>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'ultisnips' },
    }, {
        { name = 'buffer' },
    }),
    formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = function(entry, vim_item) 
            local text_kind = vim_item.kind
            vim_item.kind = kind_icons[vim_item.kind]

            local type = ({
                buffer = '[Buffer]',
                nvim_lsp = '[LSP]',
                latex_symbols = '[LaTeX]',
                path = '[Path]',
            })[entry.source.name]

            vim_item.menu = "    (" .. text_kind .. ')'

            if type ~= nil then
                vim_item.menu = vim_item.menu .. ' ' .. type
            end

            return vim_item
        end
    }
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
-- cmp.setup.cmdline(':', {
--     mapping = cmp.mapping.preset.cmdline(),
--     sources = cmp.config.sources({
--         { name = 'path' }
--     }, {
--         { name = 'cmdline' }
--     })
-- })

vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { fg = "#EADFF0", bg = "#A377BF" })

local function open_in_split(split_cmd, cmd)
  return function()
    vim.cmd(split_cmd)
    cmd()
  end
end

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
    vim.keymap.set('n', '<localleader>ls', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<localleader>lt', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<localleader>lm', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<localleader>la', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', '<localleader>lr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<localleader>lf', vim.lsp.buf.formatting, bufopts)

    vim.keymap.set(
        'n',
        '<localleader>lis',
        open_in_split('split', vim.lsp.buf.implementation),
        bufopts
    )
    vim.keymap.set(
        'n',
        '<localleader>liv',
        open_in_split('vsplit', vim.lsp.buf.implementation),
        bufopts
    )
    vim.keymap.set(
        'n',
        '<localleader>lit',
        open_in_split('tab', vim.lsp.buf.implementation),
        bufopts
    )
end

-- nvim's builtin lsp
require('lspconfig').eslint.setup{ on_attach = on_attach }
require('lspconfig').tsserver.setup{ on_attach = on_attach }
