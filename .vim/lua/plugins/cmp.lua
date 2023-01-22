local kind_icons = require('lsp_common').kind_icons

local cmp = require('cmp')

local function format_entry(entry, vim_item)
    local text_kind = vim_item.kind
    vim_item.kind = ' ' .. (kind_icons[vim_item.kind] or '')

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

cmp.setup{
    snippet = {
        expand = function(args)
            vim.fn['UltiSnips#Anon'](args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<c-j>'] = cmp.mapping.select_next_item(),
        ['<c-k>'] = cmp.mapping.select_prev_item(),
        ['<c-b>'] = cmp.mapping.scroll_docs(-4),
        ['<c-f>'] = cmp.mapping.scroll_docs(4),
        ['<c-e>'] = cmp.mapping.abort(),
        ['<c-y>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'ultisnips' },
        { name = 'buffer' },
    }),
    formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = format_entry,
    }
}

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    formatting = {
        fields = { 'kind', 'abbr', 'menu' },
    },
    mapping = {
        ['<C-j>'] = {
            c = function()
                if cmp.visible() then
                    cmp.select_next_item()
                end
            end
        },
        ['<C-k>'] = {
            c = function()
                if cmp.visible() then
                    cmp.select_prev_item()
                end
            end
        },
        ['<C-e>'] = {
            c = cmp.mapping.close(),
        },
        ['<Tab>'] = cmp.config.disable
    },
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

-- local function inverse_hl(name, fg_color)
    --     local color = vim.api.nvim_get_hl_by_name(name, true)

    --     if color ~= nil then
    --         vim.api.nvim_set_hl(0, name, { fg = fg_color or color.background or 'black', bg = color.foreground })
    --     end
-- end

-- function inverse_cmp_item_kinds()
--     inverse_hl('CmpItemKindFunction')
-- end

-- vim.cmd([[
--     augroup InvertCmpItemKinds
--         autocmd!
--         autocmd ColorScheme * lua inverse_cmp_item_kinds()
--     augroup END
-- ]])

-- inverse_hl('CmpItemKindFunction')

-- vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { fg = "#EADFF0", bg = "#A377BF" })
