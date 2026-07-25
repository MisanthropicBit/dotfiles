---@type config.PluginSpec
return {
    src = "https://www.github.com/windwp/nvim-autopairs",
    version = "59bce2eef357189c3305e25bc6dd2d138c1683f5",
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
