local map = require("config.map")

-- Useful git mappings based on the spf13-vim distribution
map.n.leader("gs", "<cmd>G<cr>")
map.n.leader("gd", "<cmd>Gdiffsplit<cr>")
map.n.leader("gc", "<cmd>G commit<cr>")
map.n.leader("gb", "<cmd>G blame<cr>")
map.n.leader("gl", "<cmd>Term git log<cr>")
map.n.leader("gp", "<cmd>G push<cr>")
map.n.leader("gv", "<cmd>vert G --paginate diff --cached<cr>")
map.n.leader("gw", "<cmd>Gwrite<cr>")
map.n.leader("gu", "<cmd>GBrowse!<cr>")
map.leader({ "v", "x" }, "gu", ":GBrowse!<cr>")
map.n.leader("gos", "<cmd>Gsp origin/master:%<cr>")
map.n.leader("gov", "<cmd>Gvs origin/master:%<cr>")
map.n.leader("got", "<cmd>Gtabedit origin/master:%<cr>")

vim.api.nvim_create_user_command("Gom", "<cmd><mods> Gsp origin/master:%", {})
