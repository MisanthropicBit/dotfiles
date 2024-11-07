local map = require("config.map")

vim.opt_local.spell = true
vim.opt_local.colorcolumn = "50"

local options = { buffer = true, expr = true }

map.i("skci", function() return "[skip ci]" end, options)
map.i("cisk", function() return "[ci skip]" end, options)
map.i("icom", function() return "Initial commit" end, options)
map.i("prco", function() return "PR comments" end, options)
