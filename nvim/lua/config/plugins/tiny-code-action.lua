return {
    src = "https://www.github.com/rachartier/tiny-code-action.nvim",
    data = {
        config = {
            backend = vim.fn.executable("delta") == 1 and "delta" or "vim",
            picker = "fzf-lua",
        },
    },
}
