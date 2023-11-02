local map = require("config.map")

local function visual_indent_reselect(dir)
    vim.cmd("normal! " .. dir .. "")
    vim.cmd([[normal! gv]])
end

local conflict_marker_regex = [[^\(\(\(<<<<<<<\)\|\(|||||||\)\|\(>>>>>>>\)\) .\+\|\(=======\)\)]]

local function find_git_conflict_marker(dir)
    vim.fn.search(conflict_marker_regex, dir == 1 and "w" or "bw")
end

map.leader("n", "<space>", "<cmd>nohl<cr>")
map.leader("n", "w", "<cmd>w<cr>")
map.leader("n", "q", "<cmd>q<cr>")
map.leader("n", "Q", "<cmd>qa!<cr>")
map.leader("n", "vs", "<cmd>sp $MYVIMRC<cr>")
map.leader("n", "vv", "<cmd>vsp $MYVIMRC<cr>")
map.leader("n", "vt", "<cmd>tabe $MYVIMRC<cr>")
map.leader("n", "sv", "<cmd>source $MYVIMRC<cr>")
map.leader("n", "1", "1z=", "Correct misspelled word under cursor with its first suggestion")
map.leader("n", "fl", "za")
map.leader("n", "k", "K")
map.leader("n", "it", "<cmd>Inspect<cr>", "Inspect treesitter node under cursor")
map.leader("n", "pt", function()
    vim.cmd("tabnext " .. vim.g.last_tab)
end)
map.leader("n", "ct", function()
    vim.fn.setreg("+", vim.fn.expand("%:t"))
end)
map.leader("n", "ch", function()
    vim.fn.setreg("+", vim.fn.expand("%:h"))
end)
map.leader("n", "cp", function()
    vim.fn.setreg("+", vim.fn.expand("%:p"))
end)

map.n("<c-o>", "<c-o>zz")
map.n("<c-i>", "<c-i>zz")
map.n("<c-h>", "<c-w>h")
map.n("<c-j>", "<c-w>j")
map.n("<c-k>", "<c-w>k")
map.n("<c-l>", "<c-w>l")
map.n("Q", "@@")
map.n("j", "gj")
map.n("k", "gk")
map.n("gf", "<c-w>gf")
map.n("*", "*Nzz")
map.n("n", "nzvzz")
map.n("N", "Nzvzz")
map.n("<c-t><c-o>", "<cmd>tabonly<cr>")
map.n("H", "gT")
map.n("L", "gt")
map.n("g0", "<cmd>tabnext 1<cr>")
map.n("g$", "<cmd>tabnext $<cr>")
map.n("<c-t><c-s>", "<cmd>Term<cr>")
map.n("<c-t><c-v>", "<cmd>vert Term<cr>")
map.n("<c-t><c-t>", "<cmd>tab Term<cr>")
map.n("<c-w>m", "<cmd>Winmove move<cr>")
map.n("<c-w>i", "<cmd>Winmove resize<cr>")
map.n(">m", function()
    find_git_conflict_marker(1)
end)
map.n("<m", function()
    find_git_conflict_marker(-1)
end)

map.i("jk", [["<esc>"]], { expr = true })
map.i("<c-a>", "<c-o>^", "Move to start of line in insert mode")
map.i("<c-e>", "<c-o>$", "Move to end of line in insert mode")

map.v(">", function()
    visual_indent_reselect(">")
end)
map.v("<", function()
    visual_indent_reselect("<")
end)

-- Otherwise, nothing will be echoed on the commandline initially
local cmap_options = { silent = false }

map.c("<c-a>", "<c-b>", cmap_options)
map.c("<m-left>", "<c-left>", cmap_options)
map.c("<m-right>", "<c-right>", cmap_options)
map.c("<c-h>", "<c-left>", cmap_options)
map.c("<c-l>", "<c-right>", cmap_options)
map.c("<c-o>", "origin/master:", cmap_options)
map.c("<c-b>", "<c-r>=printf('origin/%s', FugitiveHead())<cr>", cmap_options)
map.c("<c-d>", "<c-r>=expand('%:p:h') . '/'<cr>", cmap_options)

map.t("jk", [[<c-\><c-n>]])

if not vim.g.vscode then
    -- Very magic modifier does not work in vscode
    map.n("/", [[/\v]], cmap_options)
    map.v("/", [[/\v]], cmap_options)
end
