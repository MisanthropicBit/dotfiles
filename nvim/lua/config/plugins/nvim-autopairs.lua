return {
    src = "https://www.github.com/windwp/nvim-autopairs",
    data = {
        config = function(autopairs)
            autopairs.setup({
                fastwrap = {
                    map = "<c-q>",
                    end_key = "m"
                }
            })
        end
    }
}
