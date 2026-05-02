---@type config.PluginSpec
return {
    src = "https://www.github.com/kevinhwang91/nvim-bqf",
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
