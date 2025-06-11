local tabline = {}

local fileinfo = require("config.utils.fileinfo")
local highlight = require("config.highlight")
local icons = require("config.icons")

tabline.options = {
    left_separator = icons.separators.high_slant_lower_right,
    right_separator = icons.separators.high_slant_upper_left,
    spacing = 1,
}

---@param tab string[]
---@param value string
---@param selected boolean
---@param options table?
local function render(tab, value, selected, options)
    if not options then
        table.insert(tab, value)
        return
    end

    if options.hl_group then
        table.insert(tab, ("%%#%s#%s"):format(options.hl_group, value))
    elseif options.color then
        if not options.filetype then
            error("options.filetype required with options.color")
        end

        local name = ("TabLine%sIcon%s"):format(options.filetype, selected and "Sel" or "")
        local bg = selected and "TabLineSel" or "TabLine"
        highlight.create_hl_from(0, name, { fg = { options.color, "fg" }, bg = { bg, "bg" } })

        table.insert(tab, ("%%#%s#%s"):format(name, value))
    end
end

---@param bufnr integer
---@return FileInfo
local function get_filename(bufnr)
    local info = fileinfo.get(bufnr)
    local path = info.path
    local root = vim.fs.root(path, { ".git" })

    if root and vim.startswith(path, root) then
        -- '+ 2' for prefix itself and the following '/'
        path = path:sub(#root + 2)
    end

    return vim.tbl_extend("force", info, {
        path = vim.fn.pathshorten(path, 3),
    })
end

---@param tabpage integer
local function get_tab_context(tabpage)
    local winnr = vim.api.nvim_tabpage_get_win(tabpage)
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    local filetype = vim.bo[bufnr].filetype
    local info = get_filename(bufnr)

    return {
        tabnr = vim.api.nvim_tabpage_get_number(tabpage),
        selected = tabpage == vim.api.nvim_get_current_tabpage(),
        winnr = winnr,
        bufnr = bufnr,
        filename = info.path,
        modified = vim.bo[bufnr].modified,
        filetype = filetype,
        icon = info.icon,
        rgb = info.icon_color,
    }
end

---@param tabpage integer
local function render_tab(tabpage, options)
    local context = get_tab_context(tabpage)
    local selected = context.selected
    local tab = {}

    if options.left_separator then
        local sep_color = selected and "TabLineLeftSepSel" or "TabLineLeftSep"
        render(tab, options.left_separator .. " ", selected, { hl_group = sep_color })
    end

    render(tab, " " .. context.filename .. " ", selected, { hl_group = selected and "TabLineSel" or "TabLine" })

    if context.icon then
        render(tab, context.icon, selected, { color = context.rgb, filetype = context.filetype })
    else
        render(tab, icons.misc.help, selected)
    end

    if context.modified then
        local group = selected and "TabLineModifiedSel" or "TabLineModified"
        render(tab, " " .. icons.test.running, selected, { hl_group = group })
    end

    render(tab, " ", selected)

    if options.right_separator then
        local sep_color = selected and "TabLineRightSepSel" or "TabLineRightSep"

        render(tab, options.right_separator, selected, { hl_group = sep_color })
    end

    render(tab, (" "):rep(options.spacing), selected, { hl_group = "TabLineFill" })

    return table.concat(tab)
end

function tabline.render()
    local tabpages = vim.api.nvim_list_tabpages()
    local result = {}

    render(result, "󰂺 " .. tostring(#vim.api.nvim_list_tabpages()) .. " ", false, { hl_group = "Title" })
    render(result, tabline.options.right_separator .. " ", false, { hl_group = "TabLineRightSep" })

    for _, tabpage in ipairs(tabpages) do
        table.insert(result, render_tab(tabpage, tabline.options))
    end

    render(result, "%=", false, { hl_group = "TabLineFill" })

    return table.concat(result)
end

local function create_separator_highlights()
    -- TODO: If TabLineFill links to TabLine, create a new one

    -- local fill_group = "TabLineFill"
    -- local tabline_fill = vim.api.nvim_get_hl(0, { name = "TabLineFill" })
    -- vim.print(tabline_fill)
    --
    -- if tabline_fill.link and tabline_fill.link == "TabLine" then
    --     highlight.create_hl_from(
    --         0,
    --         "TabLineFillAlt",
    --         { fg = { "Normal", "fg" }, bg = { "Title", "fg" } }
    --     )
    --     fill_group = "TabLineFillAlt"
    -- end

    highlight.create_hl_from(0, "TabLineLeftSepSel", { fg = { "TabLineSel", "bg" }, bg = { "TabLineFill", "bg" } })
    highlight.create_hl_from(0, "TabLineLeftSep", { fg = { "TabLine", "bg" }, bg = { "TabLineFill", "bg" } })
    highlight.create_hl_from(0, "TabLineRightSepSel", { fg = { "TabLineSel", "bg" }, bg = { "TabLineFill", "bg" } })
    highlight.create_hl_from(0, "TabLineRightSep", { fg = { "TabLine", "bg" }, bg = { "TabLineFill", "bg" } })
    highlight.create_hl_from(0, "TabLineModified", { fg = { "WarningMsg", "fg" }, bg = { "TabLine", "bg" } })
    highlight.create_hl_from(0, "TabLineModifiedSel", { fg = { "WarningMsg", "fg" }, bg = { "TabLineSel", "bg" } })
end

function tabline.register()
    create_separator_highlights()

    vim.api.nvim_create_autocmd("Colorscheme", { callback = create_separator_highlights })
    vim.api.nvim_create_autocmd("TabNew", {
        callback = function()
            tabline.render()
        end,
    })

    vim.o.tabline = [[%!v:lua.require'config.tabline'.render()]]
end

return tabline
