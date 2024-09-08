local map = require("config.map")

local options = { buffer = true }

map.n("<c-n>", "<cmd>keepjumps cnext <bar> wincmd p<cr>", options)
map.n("<c-p>", "<cmd>keepjumps cprev <bar> wincmd p<cr>", options)
map.n("<c-h>", "<cmd>colder<cr>", options)
map.n("<c-l>", "<cmd>cnewer<cr>", options)
map.n("qs", "<c-w><cr>", options)
map.n("qv", "<c-w><cr><c-w>L<c-w>p<c-w>J<c-w>p", options)
map.n("qt", "<c-w><cr><c-w>T", options)
