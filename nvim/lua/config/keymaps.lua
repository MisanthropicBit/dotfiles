local map = require("config.map")

local conflict_marker_regex = [[^\(\(\(<<<<<<<\)\|\(|||||||\)\|\(>>>>>>>\)\) .\+\|\(=======\)\)]]

local function find_git_conflict_marker(dir)
    vim.fn.search(conflict_marker_regex, dir == 1 and "w" or "bw")
end

-- Root directory markers
local markers = {
    ".editorconfig",
    ".eslintrc",
    ".git",
    ".gitignore",
    "Dockerfile",
    "babel.config.json",
    "cloudbuild.yaml",
    "eslint.config.js",
    "jest.config.js",
    "package.json",
    "tsconfig.json",
}

---@return string?
local function get_project_root()
    return vim.fs.basename(vim.fs.root(0, markers))
end

map.n.leader("<space>", "<cmd>nohl<cr>")
map.n.leader("w", "<cmd>w<cr>")
map.n.leader("q", "<cmd>q<cr>")
map.n.leader("x", "<cmd>x<cr>")
map.n.leader("Q", "<cmd>qa!<cr>")
map.n.leader("sv", "<cmd>source $MYVIMRC<cr>")
map.n.leader("1", "1z=", "Correct misspelled word under cursor with the first suggestion")
map.n.leader("fl", "za")
map.n.leader("k", "K")
map.n.leader("ip", "<cmd>Inspect<cr>", "Inspect treesitter node under cursor")
map.n.leader("pt", function()
    vim.cmd("tabnext " .. vim.g.last_tab)
end)
map.n.leader("ct", function()
    vim.fn.setreg("+", vim.fn.expand("%:t"))
end, "Copy tail of current file path")
map.n.leader("ch", function()
    vim.fn.setreg("+", vim.fn.expand("%:h"))
end, "Copy head of current file path")
map.n.leader("cf", function()
    vim.fn.setreg("+", vim.fn.expand("%:p"))
end, "Copy current [f]ull file path")
map.n.leader("cr", function()
    vim.fn.setreg("+", get_project_root())
end, "Copy current repository name")
map.n.leader("cR", function()
    vim.fn.setreg("+", ("`%s`"):format(get_project_root()))
end, "Copy current repository name formatted as inline markdown code")
map.n.leader("rp", "<cmd>setlocal wrap!<cr>")
map.n.leader("de", "<cmd>e %:h<cr>")
map.n.leader("ds", "<cmd>sp %:h<cr>")
map.n.leader("dv", "<cmd>vs %:h<cr>")
map.n.leader("dt", "<cmd>tabe %:h<cr>")
map.n.leader("cp", "<cmd>cprev<cr>")
map.n.leader("cn", "<cmd>cnext<cr>")
map.n.leader("ve", "vg_")
map.n.leader("sa", "ggVGo0")
map.n.leader("cx", "<cmd>!chmod u+x %<cr>", "Make current file executable by user")
map.n.leader("yp", "viwp", "Paste last yank over word under cursor")
map.n.leader("y0", '<cmd>normal! viw"0p<cr>', "Paste register 0 over word under cursor")
map.n.leader("mn", function()
    find_git_conflict_marker(1)
end)
map.n.leader("mp", function()
    find_git_conflict_marker(-1)
end)
map.n.leader("yj", function()
    vim.cmd("+" .. vim.v.count .. "yank")
end, "Yank line [count] below current line")
map.n.leader("yk", function()
    vim.cmd("-" .. vim.v.count .. "yank")
end, "Yank line [count] above current line")
map.n.leader("0", "<c-w>=")
map.n.leader("bb", "<cmd>FzfLua buffers<cr>", { condition = "!fzf-lua" })

map.n("<c-o>", "<c-o>zz")
map.n("<c-i>", "<c-i>zz")
map.n("<c-h>", "<c-w>h")
map.n("<c-j>", "<c-w>j")
map.n("<c-k>", "<c-w>k")
map.n("<c-l>", "<c-w>l")
map.n("j", "gj")
map.n("k", "gk")
map.n("gf", "<c-w>gf", { condition = "!fzf-lua" }) -- TODO: Runs before plugin setup
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
map.n("<c-w>m", function()
    require("winmove").start_mode("move")
end)
map.n("<c-w>r", function()
    require("winmove").start_mode("resize")
end)
map.n("<c-w>x", function()
    require("winmove").start_mode("swap")
end)
map.n("<c-w>X", function()
    require("winmove").swap_window(0)
end)
map.n("<c-b><c-n>", "<cmd>bnext<cr>")
map.n("<c-b><c-p>", "<cmd>bprevious<cr>")
map.n("<c-s-h>", "zH")
map.n("<c-s-l>", "zL")
map.n("dd", function()
    -- Delete pure whitespace line into the black hole register
    if vim.api.nvim_get_current_line():match("^%s*$") then
        return '"_dd'
    else
        return "dd"
    end
end, { expr = true })
map.n("<c-b><c-l>", function()
    local has_useopen = vim.tbl_contains(vim.opt.switchbuf:get(), "useopen")

    if not has_useopen then
        vim.opt.switchbuf:append("useopen")
    end

    vim.cmd("sbuffer #")

    if not has_useopen then
        vim.opt.switchbuf:remove("useopen")
    end
end, "Navigate to last visited buffer or open new window")
map.n("<bs>", "^")

map.i("jk", [["<esc>"]], { expr = true })
map.i("<c-a>", "<c-o>^", "Move to start of line in insert mode")
map.i("<c-e>", "<c-o>$", "Move to end of line in insert mode")

map.v.leader("sc", [[<cmd>s/\v\s*,\s*/\r/g<cr><esc><cmd>nohl<cr>]], "Replace all commas in visual selection with newlines")

-- Otherwise, nothing will be echoed on the commandline initially
local cmap_options = { silent = false }

map.c("<c-a>", "<c-b>", cmap_options)
map.c("<m-left>", "<c-left>", cmap_options)
map.c("<m-right>", "<c-right>", cmap_options)
map.c("<c-h>", "<c-left>", cmap_options)
map.c("<c-l>", "<c-right>", cmap_options)
map.c("<c-o>", "origin/master:", cmap_options)
map.c("<c-b>", "<c-r>=printf('origin/%s', FugitiveHead())<cr>", {
    silent = false,
    condition = function()
        return vim.fn.exists("*FugitiveHead")
    end
})
map.c("<c-d>", "<c-r>=expand('%:p:h') . '/'<cr>", cmap_options)
map.c("<c-t>", "<c-r>=expand('%:p:t')<cr>", cmap_options)
map.c("<c-y>", function()
    vim.fn.setreg('"', vim.fn.getcmdline())
end)

map.t("jk", [[<c-\><c-n>]])

if not vim.g.vscode then
    -- Very magic modifier does not work in vscode
    map.n("/", [[/\v]], cmap_options)
    map.v("/", [[/\v]], cmap_options)
end
