---@type config.PluginSpec
return {
    src = "https://www.github.com/kevinhwang91/nvim-bqf",
    version = "c282a62bec6c0621a1ef5132aa3f4c9fc4dcc2c7",
    data = {
        config = {
            filter = {
                fzf = {
                    ["ctrl-s"] = {
                        description = "Open item in a new horizontal split",
                        default = "split",
                    },
                },
            },
        },
    },
}
