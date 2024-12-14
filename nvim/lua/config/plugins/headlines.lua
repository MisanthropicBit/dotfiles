return {
    "lukas-reineke/headlines.nvim",
    ft = "markdown",
    config = function()
        require("headlines").setup({
            markdown = {
                -- Breaks with some patched fonts like RobotoMono Nerd font
                fat_headlines = false,
                bullets = { "󰲠 ", "󰲢 ", "󰲤 ", "󰲦 " },
            },
        })
    end,
}
