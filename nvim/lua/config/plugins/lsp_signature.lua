return {
    "ray-x/lsp_signature.nvim",
    config = function()
        local lsp_utils = require("config.lsp.utils")

        require("lsp_signature").setup({
            close_timeout = 2000,
            always_trigger = false,
            hint_prefix = lsp_utils.kind_icons.Method,
            select_signature_key = "<c-s>",
            timer_interval = 100,
        })
    end,
}
