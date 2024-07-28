local icons = require("config.icons")
local helpers = require("incline.helpers")
local devicons = require("nvim-web-devicons")

local function get_diagnostic_label(props)
    local label = {}

    for _, severity in pairs({ "error", "warn" }) do
        local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[severity:upper()] })
        local icon = icons.diagnostics[severity]

        if n > 0 then
            table.insert(label, { icon .. n .. " ", group = "DiagnosticSign" .. severity })
        end
    end

    if #label > 0 then
        table.insert(label, { " " })
    end

    return label
end

local function render(props)
    local bufname = vim.api.nvim_buf_get_name(props.buf)
    local filename = vim.fn.fnamemodify(bufname, ":t")

    if filename == "" then
        filename = icons.files.new
    end

    local ft_icon, ft_color = devicons.get_icon_color(filename)
    local modified = vim.bo[props.buf].modified

    if vim.startswith(bufname, "oil://") then
        filename = "oil"
        ft_icon = icons.files.oil
        ft_color = ({ devicons.get_icon_color_by_filetype("txt") })[2]
    elseif vim.startswith(bufname, "fugitive://") then
        filename = "fugitive"
        ft_icon, ft_color = devicons.get_icon_color_by_filetype("git")
    end

    return {
        ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
        " ",
        { filename, gui = modified and "bold,italic" or "bold" },
        " ",
        { modified and (icons.test.running .. " ") or "", group = "diffChanged" },
        get_diagnostic_label(props),
        group = "NormalFloat",
    }
end

require("incline").setup({
    hide = {
        cursorline = true,
    },
    ignore = {
        buftypes = {},
    },
    window = {
        padding = 0,
        margin = { horizontal = 0 },
        overlap = {
            borders = true,
        },
        zindex = 30,
    },
    render = render,
})
