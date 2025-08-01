local tabline = {}

local fileinfo = require("config.utils.fileinfo")
local highlight = require("config.highlight")
local icons = require("config.icons")

local function apply_padding(value, options)
    if options then
        if options.pad_left and options.pad_left > 0 then
            return (" "):rep(options.pad_left) .. value
        end

        if options.pad_right and options.pad_right > 0 then
            return value .. (" "):rep(options.pad_right)
        end
    end

    return value
end

---@param tab string[]
---@param value string
---@param selected boolean
---@param options table?
local function render(tab, value, selected, options)
    if not value or #value == 0 then
        return
    end

    if not options then
        table.insert(tab, value)
        return
    end

    local rendered = ""

    if options.hl_group then
        local _hl_group = selected and options.hl_group .. "Sel" or options.hl_group
        rendered = ("%%#%s#%s"):format(_hl_group, apply_padding(value, options))
    elseif options.color then
        if not options.filetype then
            error("options.filetype required with options.color")
        end

        local name = ("TabLine%sIcon%s"):format(options.filetype, selected and "Sel" or "")
        local bg = selected and "TabLineSel" or "TabLine"
        highlight.create_hl_from(0, name, { fg = { options.color, "fg" }, bg = { bg, "bg" } })

        rendered = ("%%#%s#%s"):format(name, apply_padding(value, options))
    end

    table.insert(tab, rendered)
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

local function render_before()
    local result = {}

    render(result, "󰂺 " .. tostring(#vim.api.nvim_list_tabpages()) .. " ", false, { hl_group = "Title" })
    render(result, tabline.options.right_separator, false, { hl_group = "TabLineRightSep", pad_right = 1 })

    return result
end

local function render_after()
    local result = {}

    render(result, "%=", false, { hl_group = "TabLineFill" })

    return result
end

---@param tabpage integer
---@param options table
local function render_tab(tabpage, options)
    local context = get_tab_context(tabpage)
    local selected = context.selected
    local tab = {}

    render(tab, options.left_separator, selected, { hl_group = "TabLineLeftSep", pad_right = 1 })
    render(tab, context.filename, selected, { hl_group = "TabLine", pad_left = 1, pad_right = 1 })

    if context.icon then
        render(tab, context.icon, selected, { color = context.rgb, filetype = context.filetype, pad_left = 1 })
    else
        render(tab, icons.misc.help, selected)
    end

    if context.modified then
        render(tab, icons.test.running, selected, { hl_group = "TabLineModified", pad_left = 1 })
    end

    render(tab, " ", selected)
    render(tab, options.right_separator, selected, { hl_group = "TabLineRightSep" })
    render(tab, (" "):rep(options.spacing), selected, { hl_group = "TabLineFill" })

    return table.concat(tab)
end

function tabline.render()
    local tabpages = vim.api.nvim_list_tabpages()
    local result = {}

    if tabline.options.render_before then
        vim.list_extend(result, tabline.options.render_before())
    end

    for _, tabpage in ipairs(tabpages) do
        table.insert(result, tabline.options.render_tab(tabpage, tabline.options))
    end

    if tabline.options.render_after then
        vim.list_extend(result, tabline.options.render_after())
    end

    return table.concat(result)
end

--- Create custom tabline highlights for a colorscheme that uses correct
--- highlights for nerdfont separators
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

tabline.options = {
    render_before = render_before,
    render_tab = render_tab,
    render_after = render_after,
    left_separator = icons.separators.high_slant_lower_right,
    right_separator = icons.separators.high_slant_upper_left,
    spacing = 1,
}

function tabline.register()
    create_separator_highlights()

    -- Create corrected highlights every time a new colorscheme is set
    vim.api.nvim_create_autocmd("Colorscheme", { callback = create_separator_highlights })

    vim.o.tabline = [[%!v:lua.require'config.tabline'.render()]]
end

return tabline
