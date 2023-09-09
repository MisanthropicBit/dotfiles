local cmp = require('cmp')
local luasnip = require('luasnip')

local icons = require('config.icons')
local kind_icons = require('config.lsp.utils').kind_icons

-- Format autocomplete items
local function format_entry(entry, vim_item)
    local text_kind = vim_item.kind
    vim_item.kind = ' ' .. (kind_icons[vim_item.kind] or '')

    local type = icons.lsp[entry.source.name]

    if type ~= nil then
        vim_item.menu = ' ' .. type
    end

    vim_item.menu = (vim_item.menu or '') .. " (" .. text_kind .. ')'

    return vim_item
end

-- Get buffers to autocomplete text from. Gets all visible buffers with a byte limit
local function get_bufnrs()
    local function buf_bytesize(buffer)
        return vim.api.nvim_buf_get_offset(buffer, vim.api.nvim_buf_line_count(buffer))
    end

    local max_bytesize = 1024 * 1024
    local total_bytesize = 0
    local buffers = {}

    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buffer = vim.api.nvim_win_get_buf(win)
        local bytesize = buf_bytesize(buffer)

        if total_bytesize + bytesize < max_bytesize then
            table.insert(buffers, vim.api.nvim_win_get_buf(win))
            total_bytesize = total_bytesize + bytesize
        else
            break
        end
    end

    return buffers
end

cmp.setup{
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<c-j>'] = cmp.mapping(function(fallback)
            if luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<c-k>'] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            elseif cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end),
        ['<c-b>'] = cmp.mapping.scroll_docs(-4),
        ['<c-f>'] = cmp.mapping.scroll_docs(4),
        ['<c-e>'] = cmp.mapping.abort(),
        ['<c-y>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        {
            name = 'buffer',
            option = {
                get_bufnrs = get_bufnrs
            }
        },
    }),
    formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = format_entry,
    },
    -- TODO: Make lsp sources close to the cursor score higher
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
