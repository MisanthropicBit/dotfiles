local map = require("config.map")

vim.opt_local.spell = true
vim.opt_local.colorcolumn = "50"

map.i("skci", "[skip ci]", { buffer = true, expr = true })
map.i("cisk", "[ci skip]", { buffer = true, expr = true })
map.i("icom", "Initial commit", { buffer = true, expr = true })
