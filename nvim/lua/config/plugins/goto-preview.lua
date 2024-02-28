local map = require("config.map")

local goto_preview = require("goto-preview")

goto_preview.setup({
    height = 28,
    post_open_hook = function()
        vim.cmd.normal("zt")
    end,
})

map.n("gp", goto_preview.goto_preview_definition, "Preview definition under cursor")
map.n("gi", goto_preview.goto_preview_implementation, "Preview implementation under cursor")
map.n("ge", goto_preview.close_all_win, "Close all goto-preview windows")
map.n.leader("gt", goto_preview.goto_preview_type_definition, "Preview type definition under cursor")
