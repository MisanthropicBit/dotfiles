---@type config.PluginSpec
return {
    src = "https://github.com/nemanjamalesija/ts-expand-hover.nvim",
    data = {
        config = function(ts_expand_hover)
            ts_expand_hover.setup({
                keymaps = { hover = false },
            })

            local map = require("config.map")
            local autocmds = require("config.autocmds")

            -- Only overwrite the default hover for typescript files
            autocmds.create_config_autocmd("FileType", {
                pattern = { "typescript", "typescriptreact" },
                callback = function()
                    map.n("<s-m>", ts_expand_hover.hover, { check = false})
                end,
            })
        end,
    },
}
