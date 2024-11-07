local loader = require("config.plugins.loader")

local config_path = table.concat({ vim.fn.stdpath("config"), "lua", "config" }, "/")

loader.load_plugins(config_path .. "/plugins")
