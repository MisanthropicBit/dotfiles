---@type config.PluginSpec
return {
    src = "https://www.github.com/rachartier/tiny-code-action.nvim",
    version = "8e72efa075ba3154bbc4c7d1db532b03b4e68373",
    data = {
        config = {
            backend = vim.fn.executable("delta") == 1 and "delta" or "vim",
            picker = "fzf-lua",
        },
    },
}
