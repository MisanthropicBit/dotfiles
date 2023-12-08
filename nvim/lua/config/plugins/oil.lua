local oil = require("oil")
local oil_config = require("oil.config")

local function toggle_columns()
    local columns = oil_config.columns
    local has_expanded_columns = vim.fn.index(columns, "permissions") ~= -1
    local new_columns = has_expanded_columns and { "icon" } or { "icon", "permissions", "size", "mtime" }

    oil.set_columns(new_columns)
end

oil.setup({
    use_default_keymaps = false,
    keymaps = {
        ["g?"] = "actions.show_help",
        ["<cr>"] = "actions.select",
        ["<c-s>"] = "actions.select_split",
        ["<localleader>v"] = {
            callback = function()
                oil.select({ vertical = true })
            end,
            nowait = true,
            desc = "Open entry under cursor in a vertical split",
        },
        ["<c-t>"] = {
            callback = function()
                oil.select({ tab = true })
            end,
            nowait = true,
            desc = "Open entry under cursor in a tab",
        },
        ["<c-p>"] = "actions.preview",
        ["<localleader>ps"] = {
            callback = function()
                oil.select({ horizontal = true, preview = true })
            end,
            desc = "Open entry under cursor in a horizontal split",
        },
        ["<c-r>"] = "actions.refresh",
        ["<c-e>"] = "actions.close",
        ["<c-y>"] = "actions.copy_entry_path",
        -- c-m for '[m]ore info'
        ["<c-m>"] = { callback = toggle_columns, desc = "Toggle expanded columns" },
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["g."] = "actions.toggle_hidden",
    },
    win_options = {
        concealcursor = "nvi",
    },
    view_options = {
      show_hidden = true,
    },
})
