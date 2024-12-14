return {
    "iamcco/markdown-preview.nvim", 
    ft = "markdown",
    build = function()
        if vim.fn.executable('yarn') == 1 then
            vim.fn.system("cd app && yarn install")
        else
            vim.fn["mkdp#util#install"]()
        end
    end,
}
