local icons = require('icons')
local dashboard = require('dashboard')

--- Get a random quote from vim-starify if installed
---@return string[]
local function random_quote()
    if vim.g.loaded_startify == 1 then
        return vim.fn['startify#fortune#quote']()
    end

    return { '' }
end

--- Right-pad string
local dashboard_option_width = 52

local function rpad(value, size, padchar)
    local npad = size - #value

    return value .. string.rep(padchar, npad)
end

local rpad_default = function(value)
    return rpad(value, dashboard_option_width, ' ')
end

local function installed_plugin_count()
    return vim.tbl_count(vim.g.plugs or {})
end

-- Copy dashboard's default header since it isn't exported and pad the top to
-- vertically center the dashboard
local default_header = {
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ' ██████╗  █████╗ ███████╗██╗  ██╗██████╗  ██████╗  █████╗ ██████╗ ██████╗  ',
    ' ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔══██╗ ',
    ' ██║  ██║███████║███████╗███████║██████╔╝██║   ██║███████║██████╔╝██║  ██║ ',
    ' ██║  ██║██╔══██║╚════██║██╔══██║██╔══██╗██║   ██║██╔══██║██╔══██╗██║  ██║ ',
    ' ██████╔╝██║  ██║███████║██║  ██║██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝ ',
    ' ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ',
    '',
    '',
    ('%s  %d plugins installed'):format(icons.misc.package, installed_plugin_count()),
    '',
    ('%s  %s'):format(icons.color.scheme, vim.g.colors_name),
    '',
    '',
}

local key_hl = 'Number'

dashboard.setup{
    theme = 'doom',
    config = {
        header = default_header,
        center = {
            {
                icon = icons.files.new .. '  ',
                icon_hl = 'Title',
                desc = rpad_default('New file'),
                key = 'i',
                key_hl = key_hl,
                action = 'new | only',
            },
            {
                icon = icons.files.files .. '  ',
                icon_hl = 'Constant',
                desc = rpad_default('Recent files'),
                key = 'r',
                key_hl = key_hl,
                action = 'FzfLua oldfiles',
            },
            {
                icon = icons.git.logo .. '  ',
                icon_hl = 'DiffFile',
                desc = rpad_default('Git files'),
                key = 'g',
                key_hl = key_hl,
                action = 'FzfLua git_files',
            },
            {
                icon = icons.misc.search .. '  ',
                icon_hl = 'Special',
                desc = rpad_default('Find file'),
                key = 'f',
                key_hl = key_hl,
                action = 'FzfLua files',
            },
            {
                icon = icons.misc.search_files .. '  ',
                icon_hl = 'Statement',
                desc = rpad_default('Search files'),
                key = 's',
                key_hl = key_hl,
                action = 'FzfLua grep_project',
            },
            {
                icon = icons.misc.doctor .. '  ',
                icon_hl = 'DiagnosticWarning',
                desc = rpad_default('Check health'),
                key = 't',
                key_hl = key_hl,
                action = 'checkhealth',
            },
            {
                icon = icons.misc.package .. '  ',
                icon_hl = 'Identifier',
                desc = rpad_default('View plugins'),
                key = 'p',
                key_hl = key_hl,
                action = 'PlugStatus | only',
            },
            {
                icon = icons.misc.update .. '  ',
                icon_hl = 'Identifier',
                desc = rpad_default('Update plugins'),
                key = 'u',
                key_hl = key_hl,
                action = 'PlugUpdate | only',
            },
            {
                icon = icons.misc.config .. '  ',
                icon_hl = 'Function',
                desc = rpad_default('Dotfiles'),
                key = 'd',
                key_hl = key_hl,
                action = "lua require('fzf-lua').files({ cwd = vim.fn.stdpath('config') })"
            },
            {
                icon = icons.misc.help .. '  ',
                icon_hl = 'Question',
                desc = rpad_default('Help'),
                key = 'h',
                key_hl = key_hl,
                action = 'FzfLua help_tags',
            },
            {
                icon = icons.misc.exit .. '  ',
                icon_hl = 'DiagnosticError',
                desc = rpad_default('Quit'),
                key = 'q',
                key_hl = key_hl,
                action = 'quit'
            }
        },
        footer = random_quote,
    }
}
