local icons = require("config.icons")
local dashboard = require("dashboard")

local function wrap_lines(lines, max_width)
    local new_lines = {}

    for _, line in ipairs(lines) do
        if #line > max_width then
            -- local last_space = line:find('%s', max_width)
            vim.list_extend(new_lines, { line:sub(1, max_width), line:sub(max_width + 1, #line) })
        else
            table.insert(new_lines, line)
        end
    end

    return new_lines
end

--- Get a random quote from vim-starify if installed
---@return string[]
local function random_quote()
    if vim.g.loaded_startify == 1 then
        local quote = { "", "", "" }

        vim.list_extend(quote, vim.fn["startify#fortune#quote"]())

        return wrap_lines(quote, 100)
    end

    return { "" }
end

--- Right-pad string
local dashboard_option_width = 52

local function rpad(value, size, padchar)
    local npad = size - #value

    return value .. string.rep(padchar, npad)
end

local rpad_default = function(value)
    return rpad(value, dashboard_option_width, " ")
end

local function installed_plugin_count()
    return vim.tbl_count(vim.g.plugs or {})
end

local plugins_installed = ("%s  %d plugins installed"):format(icons.misc.package, installed_plugin_count())
local current_colorsceme = ("%s  %s"):format(icons.color.scheme, vim.g.colors_name)

local default_header = {
    "",
    "",
    "",
    "",
    "████████▄     ▄████████    ▄████████    ▄█    █▄    ▀█████████▄   ▄██████▄     ▄████████    ▄████████ ████████▄",
    "███   ▀███   ███    ███   ███    ███   ███    ███     ███    ███ ███    ███   ███    ███   ███    ███ ███   ▀███",
    "███    ███   ███    ███   ███    █▀    ███    ███     ███    ███ ███    ███   ███    ███   ███    ███ ███    ███",
    "███    ███   ███    ███   ███         ▄███▄▄▄▄███▄▄  ▄███▄▄▄██▀  ███    ███   ███    ███  ▄███▄▄▄▄██▀ ███    ███",
    "███    ███ ▀███████████ ▀███████████ ▀▀███▀▀▀▀███▀  ▀▀███▀▀▀██▄  ███    ███ ▀███████████ ▀▀███▀▀▀▀▀   ███    ███",
    "███    ███   ███    ███          ███   ███    ███     ███    ██▄ ███    ███   ███    ███ ▀███████████ ███    ███",
    "███   ▄███   ███    ███    ▄█    ███   ███    ███     ███    ███ ███    ███   ███    ███   ███    ███ ███   ▄███",
    "████████▀    ███    █▀   ▄████████▀    ███    █▀    ▄█████████▀   ▀██████▀    ███    █▀    ███    ███ ████████▀",
    "",
    "",
    ("%s / %s"):format(plugins_installed, current_colorsceme),
    "",
    "",
}

local key_hl = "Number"

dashboard.setup({
    theme = "doom",
    config = {
        header = default_header,
        center = {
            {
                icon = icons.files.new .. "  ",
                icon_hl = "Title",
                desc = rpad_default("New file"),
                key = "i",
                key_hl = key_hl,
                action = "new | only",
            },
            {
                icon = icons.files.files .. "  ",
                icon_hl = "Constant",
                desc = rpad_default("Recent files"),
                key = "r",
                key_hl = key_hl,
                action = "FzfLua oldfiles cwd_only=true",
            },
            {
                icon = icons.git.logo .. "  ",
                icon_hl = "DiffFile",
                desc = rpad_default("Git files"),
                key = "g",
                key_hl = key_hl,
                action = "FzfLua git_files",
            },
            {
                icon = " " .. " ",
                icon_hl = "Keyword",
                desc = rpad_default("Git status"),
                key = "G",
                key_hl = key_hl,
                action = "FzfLua git_status",
            },
            {
                icon = icons.misc.search .. "  ",
                icon_hl = "Special",
                desc = rpad_default("Find file"),
                key = "f",
                key_hl = key_hl,
                action = "FzfLua files",
            },
            {
                icon = icons.misc.search_files .. "  ",
                icon_hl = "Statement",
                desc = rpad_default("Search files"),
                key = "s",
                key_hl = key_hl,
                action = "FzfLua grep_project",
            },
            {
                icon = icons.misc.doctor .. "  ",
                icon_hl = "DiagnosticWarning",
                desc = rpad_default("Check health"),
                key = "t",
                key_hl = key_hl,
                action = "checkhealth",
            },
            {
                icon = icons.misc.package .. "  ",
                icon_hl = "Identifier",
                desc = rpad_default("View plugins"),
                key = "p",
                key_hl = key_hl,
                action = "PlugStatus | only",
            },
            {
                icon = icons.misc.update .. "  ",
                icon_hl = "Identifier",
                desc = rpad_default("Update plugins"),
                key = "u",
                key_hl = key_hl,
                action = "PlugUpdate | only",
            },
            {
                icon = icons.misc.config .. "  ",
                icon_hl = "Function",
                desc = rpad_default("Dotfiles"),
                key = "d",
                key_hl = key_hl,
                action = "lua require('fzf-lua').files({ cwd = vim.fn.stdpath('config') })",
            },
            {
                icon = icons.misc.help .. "  ",
                icon_hl = "Question",
                desc = rpad_default("Help"),
                key = "h",
                key_hl = key_hl,
                action = "FzfLua help_tags",
            },
            {
                icon = icons.misc.exit .. "  ",
                icon_hl = "DiagnosticError",
                desc = rpad_default("Quit"),
                key = "q",
                key_hl = key_hl,
                action = "quit",
            },
        },
        footer = random_quote,
    },
})
