local map = require('mappings')
local luasnip = require('luasnip')
local loaders = require('luasnip.loaders')
local from_lua = require('luasnip.loaders.from_lua')
local vscode = require('luasnip.loaders.from_vscode')

luasnip.setup({
    update_events = 'TextChanged,TextChangedI',
})

luasnip.filetype_extend('all', { '_' })
luasnip.filetype_extend('javascript', { 'javascript-typescript-shared' })
luasnip.filetype_extend('typescript', { 'javascript-typescript-shared' })

local function snippets_path(...)
    local paths = { ... }

    return ('%s/%s'):format(vim.fn.stdpath('config'), table.concat(paths, '/'))
end

vscode.lazy_load()
vscode.lazy_load({ paths = { snippets_path('custom-snippets') } })
from_lua.lazy_load({ paths = snippets_path('custom-snippets', 'luasnippets') })

map.set({ 'i', 's' }, '<c-i>', function()
    if luasnip.expandable() then
        luasnip.expand()
    end
end, 'Expand snippet')

map.set({ 'i', 's' }, '<c-j>', function()
    if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
    end
end, 'Jump to next position in a snippet')

map.set({ 'i', 's' }, '<c-k>', function()
    if luasnip.jumpable(-1) then
        luasnip.jump(-1)
    end
end, 'Jump to previous position in a snippet')

map.set({ 'i', 's' }, '<c-l>', function()
    if luasnip.choice_active() then
        luasnip.change_choice(1)
    end
end, 'Go through snippet choices')

map.leader('n', 'sf', function()
    loaders.edit_snippet_files({
        edit = function(file)
            vim.cmd('tabe ' .. file)
        end
    })
end)