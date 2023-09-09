local devicons = require('nvim-web-devicons')

local git_icon, git_color = devicons.get_icon_color_by_filetype('git')

devicons.setup({
    default = false,
    override = {
        icon = git_icon,
        color = git_color,
        name = 'Fugitive',
    }
})

devicons.set_icon({
    fugitive = {
        icon = git_icon,
        color = git_color,
        name = 'Fugitive',
    }
})

-- devicons.setup{
--     override = {
--         fugitive = {
--             icon = git_icon,
--             color = git_color,
--             name = 'Fugitive',
--         },
--     },
-- }
