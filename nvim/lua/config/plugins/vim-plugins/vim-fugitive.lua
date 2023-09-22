local map = require("config.map")

-- Useful git mappings based on the spf13-vim distribution
map.leader("n", "gs", "<cmd>G<cr>")
map.leader("n", "gd", "<cmd>Gdiffsplit<cr>")
map.leader("n", "gc", "<cmd>G commit<cr>")
map.leader("n", "gb", "<cmd>G blame<cr>")
map.leader("n", "gl", "<cmd>Term git log<cr>")
map.leader("n", "gp", "<cmd>G push<cr>")
map.leader("n", "gv", "<cmd>vert G --paginate diff --cached<cr>")
map.leader("n", "gw", "<cmd>Gwrite<cr>")
map.leader("n", "gu", "<cmd>GBrowse!<cr>")
map.leader("x", "gu", ":GBrowse!<cr>")
map.leader("n", "gos", "<cmd>Gsp origin/master:%<cr>")
map.leader("n", "gov", "<cmd>Gvs origin/master:%<cr>")
map.leader("n", "got", "<cmd>Gtabedit origin/master:%<cr>")

vim.api.nvim_create_user_command("Gom", "<cmd><mods> Gsp origin/master:%", {})
