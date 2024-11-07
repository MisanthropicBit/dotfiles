local surround = require("nvim-surround")

local defaults = require("nvim-surround.config").default_opts

surround.setup({
    surrounds = {
        ["8"] = defaults.surrounds[")"],
        ["9"] = defaults.surrounds["{"],
    },
})
