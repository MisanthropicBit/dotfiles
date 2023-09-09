local map = require("config.map")

vim.g.gitgutter_floating_window_options = {
    relative = "cursor",
    row = 1,
    col = 0,
    width = 42,
    height = vim.o.previewheight,
    style = "minimal",
    border = "rounded",
}
vim.g.gitgutter_set_sign_backgrounds = 1
vim.g.gitgutter_sign_added = "┃"
vim.g.gitgutter_sign_modified = "┃"
vim.g.gitgutter_sign_removed = "┃"
vim.g.gitgutter_sign_modified_removed = "║"

map.n("gj", "<Plug>(GitGutterNextHunk)zz", { noremap = false, desc = "" })
map.n("gk", "<Plug>(GitGutterPrevHunk)zz", { noremap = false, desc = "" })
map.leader("n", "hv", "<Plug>(GitGutterPreviewHunk)", { noremap = false, desc = "" })
map.leader("n", "hs", "<Plug>(GitGutterStageHunk)", { noremap = false, desc = "" })

map.o("ih", "<Plug>(GitGutterTextObjectInnerPending)", { desc = "Select inner git hunk", noremap = false })
map.o("ah", "<Plug>(GitGutterTextObjectOuterPending)", { desc = "Select a git hunk", noremap = false })
map.x("ih", "<Plug>(GitGutterTextObjectInnerVisual)", { desc = "Select inner git hunk", noremap = false })
map.x("ah", "<Plug>(GitGutterTextObjectOuterVisual)", { desc = "Select a git hunk", noremap = false })
