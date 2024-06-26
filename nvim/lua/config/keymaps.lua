local map = require("config.map")

local conflict_marker_regex = [[^\(\(\(<<<<<<<\)\|\(|||||||\)\|\(>>>>>>>\)\) .\+\|\(=======\)\)]]

local function find_git_conflict_marker(dir)
    vim.fn.search(conflict_marker_regex, dir == 1 and "w" or "bw")
end

map.n.leader("<space>", "<cmd>nohl<cr>")
map.n.leader("w", "<cmd>w<cr>")
map.n.leader("q", "<cmd>q<cr>")
map.n.leader("Q", "<cmd>qa!<cr>")
map.n.leader("vs", "<cmd>sp $MYVIMRC<cr>")
map.n.leader("vv", "<cmd>vsp $MYVIMRC<cr>")
map.n.leader("vt", "<cmd>tabe $MYVIMRC<cr>")
map.n.leader("sv", "<cmd>source $MYVIMRC<cr>")
map.n.leader("1", "1z=", "Correct misspelled word under cursor with its first suggestion")
map.n.leader("fl", "za")
map.n.leader("k", "K")
map.n.leader("ip", "<cmd>Inspect<cr>", "Inspect treesitter node under cursor")
map.n.leader("pt", function()
    vim.cmd("tabnext " .. vim.g.last_tab)
end)
map.n.leader("ct", function()
    vim.fn.setreg("+", vim.fn.expand("%:t"))
end)
map.n.leader("ch", function()
    vim.fn.setreg("+", vim.fn.expand("%:h"))
end)
map.n.leader("cp", function()
    vim.fn.setreg("+", vim.fn.expand("%:p"))
end)
map.n.leader("rp", "<cmd>setlocal wrap!<cr>")
map.n.leader("de", "<cmd>e %:h<cr>")
map.n.leader("ds", "<cmd>sp %:h<cr>")
map.n.leader("dv", "<cmd>vs %:h<cr>")
map.n.leader("dt", "<cmd>tabe %:h<cr>")
map.n.leader("cn", "<cmd>cnext<cr>")

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
map.n("<c-w>m", function() require("winmove").start_mode("move") end)
map.n("<c-w>i", function() require("winmove").start_mode("resize") end)
map.n(">m", function()
    find_git_conflict_marker(1)
end)
map.n("<m", function()
    find_git_conflict_marker(-1)
end)
map.n("<c-b><c-n>", "<cmd>bnext<cr>")
map.n("<c-b><c-p>", "<cmd>bprevious<cr>")
map.n("<c-s-h>", "zH")
map.n("<c-s-l>", "zL")
map.n("dd", function()
    if vim.api.nvim_get_current_line():match("^%s*$") then
        return '"_dd'
    else
        return "dd"
    end
end, { expr = true })

map.i("jk", [["<esc>"]], { expr = true })
map.i("<c-a>", "<c-o>^", "Move to start of line in insert mode")
map.i("<c-e>", "<c-o>$", "Move to end of line in insert mode")

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
