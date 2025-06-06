local M = {}

local ansi = require("config.utils.ansi")

-- Completion kinds
M.kind_icons = {
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
M.kind_to_hl = {
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
function M.lsp_kind_to_rgb_ansi(lsp_kind)
    local hl_name = M.kind_to_hl[lsp_kind]

    if hl_name == nil then
        return nil
    end

    return ansi.highlight_to_rgb_ansi(hl_name)
end

---@param filetype string
---@return table<any>
function M.get_active_clients_for_filetype(filetype)
    local active_clients = vim.lsp.get_active_clients()
    local clients = {}

    for _, client in ipairs(active_clients) do
        local filetypes = client.config.filetypes

        if filetypes and vim.fn.index(filetypes, filetype) ~= 1 then
            table.insert(clients, client)
        end
    end

    return clients
end

---@param buffer number
---@return table<any>
function M.get_active_clients_for_buffer(buffer)
    return vim.lsp.get_active_clients({ bufnr = buffer })
end

return M
