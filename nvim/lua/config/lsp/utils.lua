local utils = {}

local ansi = require("config.utils.ansi")

-- Completion kinds
utils.kind_icons = {
    Class = "󰠱 ",
    Color = " ",
    Constant = " ",
    Constructor = " ", -- 
    Enum = "了 ",
    EnumMember = " ",
    Event = "",
    Field = " ",
    File = " ",
    Folder = " ", -- 󰉋
    Function = " ",
    Interface = " ",
    Keyword = "󰌋 ",
    Method = "ƒ ",
    Module = " ",
    Operator = "󰆕",
    Property = " ",
    Reference = "",
    Snippet = " ",
    Struct = " ", -- 
    Text = " ",
    TypeParameter = "󰅲",
    Unit = " ",
    Value = "󰎠",
    Variable = "󰂡 ",
}

-- Map lsp kinds to default vim highlight groups
utils.kind_to_hl = {
    Class = "StorageClass",
    Color = "Type",
    Constant = "Constant",
    Constructor = "Function",
    Enum = "StorageClass",
    EnumMember = "Identifier",
    Field = "Label",
    File = "String",
    Folder = "Special",
    Function = "Function",
    Interface = "StorageClass",
    Keyword = "Keyword",
    Method = "Function",
    Module = "Special",
    Property = "Type",
    Snippet = "Special",
    Struct = "Structure",
    Text = "Normal",
    Unit = "Special",
    Value = "Number",
    Variable = "Identifier",
}

---@param lsp_kind string
---@return string?
function utils.lsp_kind_to_rgb_ansi(lsp_kind)
    local hl_name = utils.kind_to_hl[lsp_kind]

    if hl_name == nil then
        return nil
    end

    return ansi.highlight_to_rgb_ansi(hl_name)
end

return utils
