local M = {}

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

return M
