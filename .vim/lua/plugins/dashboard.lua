local icons = require('icons')
local map = require('mappings')

local dashboard = require('dashboard')

--- Get a random quote from vim-starify if installed
---@return string
local function random_quote()
    if vim.g.loaded_startify == 1 then
        return vim.fn['startify#fortune#quote']()
    end

    return { '' }
end

--- Right-pad string
local dashboard_option_width = 42

local function rpad(value, size, padchar)
    local npad = size - #value

    return value .. string.rep(padchar, npad)
end

local rpad_default = function(value)
    return rpad(value, dashboard_option_width, ' ')
end

-- dashboard.custom_header = {
--     ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
--     ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
--     ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
--     ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
--     ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
--     ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
-- }

dashboard.custom_footer = random_quote
dashboard.header_pad = 6
dashboard.center_pad = 6
dashboard.footer_pad = 6
dashboard.custom_center = {
    {
        icon = icons.files.new .. '  ',
        desc = rpad_default('New file'),
        shortcut = 'i'
    },
    {
        icon = icons.files.files .. '  ',
        desc = rpad_default('Recently opened files'),
        shortcut = 'r'
    },
    {
        icon = icons.git.logo .. '  ',
        desc = rpad_default('Git files'),
        action = 'GitFiles',
        shortcut = 'g'
    },
    {
        icon = icons.misc.search .. '  ',
        desc = rpad_default('Find File'),
        action = 'Files',
        shortcut = 'f'
    },
    {
        icon = icons.misc.package .. '  ',
        desc = rpad_default('Plugins'),
        shortcut = 'p'
    },
    {
        icon = icons.misc.config .. '  ',
        desc = rpad_default('Dotfiles'),
        shortcut = 'd'
    },
    {
        icon = icons.misc.exit .. '  ',
        desc = rpad_default('Quit'),
        shortcut = 'q'
    }
}

-- dashboard-nvim does not override keymappings (shortcuts are more like hints,
-- not actual keymaps) so set up buffer-local nowait mappings
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'dashboard',
    callback = function(args)
        local map_args = { buffer = args.buf, nowait = true }

        map.set('n', 'i', '<cmd>new | wincmd o | startinsert<cr>', map_args)
        map.set('n', 'r', '<cmd>History<cr>', map_args)
        map.set('n', 'g', '<cmd>GitFiles<cr>', map_args)
        map.set('n', 'f', '<cmd>Files<cr>', map_args)
        map.set('n', 'p', '<cmd>PlugStatus<cr>', map_args)
        map.set('n', 'd', '<cmd>Dotfiles<cr>', map_args)
        map.set('n', 'q', '<cmd>q<cr>', map_args)
    end,
    once = true,
})
