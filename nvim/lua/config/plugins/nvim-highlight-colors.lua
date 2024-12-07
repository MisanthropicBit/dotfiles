local map = require("config.map")

require('nvim-highlight-colors').setup({})

map.n.leader("hh", "<cmd>HighlightColors Toggle<cr>")
