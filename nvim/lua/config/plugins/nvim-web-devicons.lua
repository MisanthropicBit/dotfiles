---@type config.PluginSpec
return {
    src = "https://www.github.com/kyazdani42/nvim-web-devicons",
    version = "d7462543c9e366c0d196c7f67a945eaaf5d99414",
    data = {
        config = function(devicons)
            local git_icon, git_color = devicons.get_icon_color_by_filetype("git")
            local sql_icon, sql_color = devicons.get_icon_color_by_filetype("sql")

            devicons.setup({
                default = false,
                override = {
                    fugitive = {
                        icon = git_icon,
                        color = git_color,
                        name = "Fugitive",
                    },
                    oil = {
                        icon = "",
                        color = ({ devicons.get_icon_color_by_filetype("txt") })[2],
                        name = "Oil",
                    },
                    mysql = {
                        icon = sql_icon,
                        color = sql_color,
                        name = "MySQL",
                    },
                },
            })
        end,
    },
}
