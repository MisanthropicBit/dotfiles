local map = require("config.map")

map.leader("n", "dv", "<cmd>Linediff")
map.x("gl", "<Plug>(linediff-operator)", { noremap = false, desc = "" })
map.n("gl", "<Plug>(linediff-operator)", { noremap = false, desc = "" })
