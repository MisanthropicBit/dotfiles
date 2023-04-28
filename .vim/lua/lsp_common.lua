local M = {}

local ansi = require('ansi')

-- Completion kinds
M.kind_icons = {
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

-- Map lsp kinds to default vim highlight groups
M.kind_to_hl = {
    Class = 'StorageClass',
    Color = 'Type',
    Constant = 'Constant',
    Constructor = 'Function',
    Enum = 'StorageClass',
    EnumMember = 'Identifier',
    Field = 'Label',
    File = 'String',
    Folder = 'Special',
    Function = 'Function',
    Interface = 'StorageClass',
    Keyword = 'Keyword',
    Method = 'Function',
    Module = 'Special',
    Property = 'Type',
    Snippet = 'Special',
    Struct = 'Structure',
    Text = 'Normal',
    Unit = 'Special',
    Value = 'Number',
    Variable = 'Identifier',
}

function M.lsp_kind_to_rgb_ansi(lsp_kind)
    local hl_name = M.kind_to_hl[lsp_kind]

    if hl_name == nil then
        return nil
    end

    return ansi.highlight_to_rgb_ansi(hl_name)
end

return M
