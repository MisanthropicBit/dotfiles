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
local dashboard_option_width = 52

local function rpad(value, size, padchar)
    local npad = size - #value

    return value .. string.rep(padchar, npad)
end

local rpad_default = function(value)
    return rpad(value, dashboard_option_width, ' ')
end

dashboard.setup{
    theme = 'doom',
    config = {
        center = {
            {
                icon = icons.files.new .. '  ',
                icon_hl = 'Title',
                desc = rpad_default('New file'),
                key = 'i',
                key_hl = 'Number',
                action = 'new | only',
            },
            {
                icon = icons.files.files .. '  ',
                icon_hl = 'Constant',
                desc = rpad_default('Recent files'),
                key = 'r',
                key_hl = 'Number',
                action = 'FzfLua oldfiles',
            },
            {
                icon = icons.git.logo .. '  ',
                icon_hl = 'DiffFile',
                desc = rpad_default('Git files'),
                key = 'g',
                key_hl = 'Number',
                action = 'FzfLua git_files',
            },
            {
                icon = icons.misc.search .. '  ',
                icon_hl = 'Special',
                desc = rpad_default('Find File'),
                key = 'f',
                key_hl = 'Number',
                action = 'FzfLua files',
            },
            {
                icon = icons.misc.doctor .. '  ',
                icon_hl = 'DiagnosticWarning',
                desc = rpad_default('Check health'),
                key = 't',
                key_hl = 'Number',
                action = 'checkhealth',
            },
            {
                icon = icons.misc.package .. '  ',
                icon_hl = 'Identifier',
                desc = rpad_default('View plugins'),
                key = 'p',
                key_hl = 'Number',
                action = 'PlugStatus | only',
            },
            {
                icon = icons.misc.update .. '  ',
                icon_hl = 'Identifier',
                desc = rpad_default('Update plugins'),
                key = 'u',
                key_hl = 'Number',
                action = 'PlugUpdate | only',
            },
            {
                icon = icons.misc.config .. '  ',
                icon_hl = 'Function',
                desc = rpad_default('Dotfiles'),
                key = 'd',
                key_hl = 'Number',
                action = "FzfLua files stdpath('config')/.vim"
            },
            {
                icon = icons.misc.help .. '  ',
                icon_hl = 'Question',
                desc = rpad_default('Help'),
                key = 'h',
                key_hl = 'Number',
                action = 'FzfLua help_tags',
            },
            {
                icon = icons.misc.exit .. '  ',
                icon_hl = 'DiagnosticError',
                desc = rpad_default('Quit'),
                key = 'q',
                key_hl = 'Number',
                action = 'quit'
            }
        },
        footer = random_quote,
    }
}
