local map = require("config.map")
local icons = require("config.icons")

---@diagnostic disable-next-line:unused-local
local function diagnostics_indicator(count, level, diagnostics_dict, context)
    local s = " "

    for e, n in pairs(diagnostics_dict) do
        local sym = icons.diagnostics.info

        if e == "error" then
            sym = icons.diagnostics.error
        elseif e == "warning" then
            sym = icons.diagnostics.warn
        end

        s = s .. n .. sym
    end

    return s
end

require("bufferline").setup({
    options = {
        mode = "tabs",
        diagnostics = "nvim_lsp",
        color_icons = true,
        diagnostics_indicator = diagnostics_indicator,
        sort_by = "tabs",
        max_name_length = 25,
        separator_style = "slant",
        show_close_icon = false,
    },
})

map.n("gb", "<cmd>BufferLinePick<cr>", "Interactively pick a tab")
