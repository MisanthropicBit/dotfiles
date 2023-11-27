local map = require("config.map")

vim.opt_local.spell = true
vim.opt_local.colorcolumn = "50"

map.i("skci", function() return "[skip ci]" end, { buffer = true, expr = true })
map.i("cisk", function() return "[ci skip]" end, { buffer = true, expr = true })
map.i("icom", function() return "Initial commit" end, { buffer = true, expr = true })
