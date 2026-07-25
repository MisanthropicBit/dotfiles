---@type config.PluginSpec
return {
    src = "https://www.github.com/ray-x/lsp_signature.nvim",
    version = "af7e4074d85d785cf6614352ba9ad3b28a1f8a56",
    data = {
        config = function(lsp_signature)
            local lsp_utils = require("config.lsp.utils")

            lsp_signature.setup({
                close_timeout = 2000,
                always_trigger = false,
                hint_prefix = lsp_utils.kind_icons.Method,
                select_signature_key = "<c-s>",
                timer_interval = 100,
            })
        end,
    },
}
