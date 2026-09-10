---@type config.PluginSpec
return {
    src = "https://www.github.com/echasnovski/mini.move",
    version = "48fcaac289a19b8eff2fd5fe203267d478a8abdc",
    data = {
        config = {
            mappings = {
                left = "H",
                right = "L",
                down = "J",
                up = "K",
                line_up = "K",
                line_down = "J",
                line_left = "",
                line_right = "",
            },
            options = {
                reindent_linewise = true,
            },
        },
    },
}
