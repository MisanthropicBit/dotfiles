local map = require("config.map")

map.n("<c-n>", "<cmd>keepjumps cnext <bar> wincmd p<cr>", { buffer = true })
map.n("<c-p>", "<cmd>keepjumps cprev <bar> wincmd p<cr>", { buffer = true })
map.n("qs", "<c-w><cr>", { buffer = true })
map.n("qv", "<c-w><cr><c-w>L<c-w>p<c-w>J<c-w>p", { buffer = true })
map.n("qt", "<c-w><cr><c-w>T", { buffer = true })
