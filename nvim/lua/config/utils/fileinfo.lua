local fileinfo = {}

local icons = require("config.icons")

---@class FileInfo
---@field name       string
---@field path       string
---@field icon       string
---@field icon_color string

local _, txt_icon_color, _ = icons.get_for_filetype("txt")

--- Get filename information from a buffer
---@param buffer integer
---@return FileInfo
function fileinfo.get(buffer)
    local bufname = vim.api.nvim_buf_get_name(buffer)

    if vim.startswith(bufname, "fugitive://") then
        local icon, icon_color, _ = icons.get_for_filetype("git")

        return {
            name = "fugitive",
            path = "fugitive",
            icon = icon,
            icon_color = icon_color,
        }
    elseif vim.startswith(bufname, "oil://") then
        local no_oil = vim.fn.trim(bufname:sub(7), "/", 2)
        local head = vim.fn.fnamemodify(no_oil, ":h") .. "/"
        local tail = vim.fn.fnamemodify(no_oil, ":t")

        return {
            name = vim.fn.pathshorten(head, 2) .. tail,
            path = bufname,
            icon = icons.files.oil,
            icon_color = txt_icon_color,
        }
    elseif vim.startswith(vim.bo[buffer].filetype, "neotest") then
        return {
            name = "neotest",
            path = vim.bo[buffer].filetype,
            icon = icons.test.passed,
            icon_color = txt_icon_color,
        }
    elseif vim.bo[buffer].filetype == "fzf" then
        local _, icon_color, _ = icons.get_for_filetype("lua")

        return {
            name = "fzf-lua",
            path = vim.bo[buffer].filetype,
            icon = icons.misc.search,
            icon_color = icon_color,
        }
    elseif bufname == "" then
        return {
            name = "New file",
            path = bufname,
            icon = icons.files.new,
            icon_color = txt_icon_color,
        }
    end

    local icon, icon_color, _ = icons.get_for_filetype(vim.bo[buffer].filetype)

    return {
        name = vim.fn.fnamemodify(bufname, ":t"),
        path = bufname,
        icon = icon,
        icon_color = icon_color,
    }
end

return fileinfo
