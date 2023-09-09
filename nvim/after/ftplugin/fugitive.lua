local map = require("config.map")

map.n("cvv", "<cmd>vert G commit<cr>", { buffer = true })
map.n("-", "<Plug>fugitive:-zz", { buffer = true })

-- I go to unstaged files way more often than untracked files
map.n("gu", "<Plug>fugitive:gU", { buffer = true })
map.n("gU", "<Plug>fugitive:gu", { buffer = true })

map.n("s", "<Plug>fugitive:o", { buffer = true })
map.n("v", "<Plug>fugitive:gO", { buffer = true })
map.n("t", "<Plug>fugitive:O", { buffer = true })
