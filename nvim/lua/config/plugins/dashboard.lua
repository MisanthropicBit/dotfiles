return {
    "nvimdev/dashboard-nvim",
    config = function()
        local icons = require("config.icons")
        local dashboard = require("dashboard")
        local key_hl = "Number"
        local images = {
            {
                file_path = "keyboard-dolphin.txt",
                file_width = 48,
                file_height = 32,
            },
            {
                file_path = "neovim-logo.txt",
                file_width = 50,
                file_height = 32,
            },
        }

        ---@param lines string[]
        ---@param max_width integer
        ---@return string[]
        local function wrap_lines(lines, max_width)
            local new_lines = {}

            for _, line in ipairs(lines) do
                local words = vim.split(line, "%s+")
                local width = 0
                local wrapped_lines = {}

                for _, word in ipairs(words) do
                    if width >= max_width then
                        table.insert(new_lines, table.concat(wrapped_lines, " "))
                        wrapped_lines = {}
                        width = 0
                    end

                    table.insert(wrapped_lines, word)
                    width = width + #word
                end

                if #wrapped_lines > 0 then
                    table.insert(new_lines, table.concat(wrapped_lines, " "))
                end
            end

            return new_lines
        end

        local function installed_plugin_count()
            return require("lazy").stats().count
        end

        --- Get a random quote from vim-starify if installed
        ---@return string[]
        local function random_quote()
            local plugins_installed = ("%s  %d plugins installed"):format(icons.misc.package, installed_plugin_count())
            local current_colorsceme = ("%s  %s"):format(icons.color.scheme, vim.g.colors_name)
            local footer = { "", "" }

            table.insert(footer, ("%s    %s"):format(plugins_installed, current_colorsceme))

            if vim.g.loaded_startify == 1 then
                local quote = { "", "", "" }

                vim.list_extend(quote, vim.fn["startify#fortune#quote"]())
                vim.list_extend(footer, wrap_lines(quote, 100))
            end

            return footer
        end

        --- Right-pad string
        local dashboard_option_width = 52

        ---@param value string
        ---@param size integer
        ---@param padchar string
        ---@return string
        local function rpad(value, size, padchar)
            local npad = size - #value

            return value .. string.rep(padchar, npad)
        end

        ---@param value string
        ---@return string
        local rpad_default = function(value)
            return rpad(value, dashboard_option_width, " ")
        end

        local function select_random_image()
            local image_info = images[math.random(1, #images)]

            return {
                file_path = vim.fn.stdpath("config") .. "/lua/config/images/" .. image_info.file_path,
                file_width = image_info.file_width,
                file_height = image_info.file_height,
            }
        end

        dashboard.setup({
            theme = "doom",
            preview = vim.tbl_extend(
            "force",
            { command = "cat | cat", }, -- https://github.com/nvimdev/dashboard-nvim/issues/193
            select_random_image()
            ),
            config = {
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
                        icon = "󱋡  ",
                        icon_hl = "Constant",
                        desc = rpad_default("All recent files"),
                        key = "R",
                        key_hl = key_hl,
                        action = "FzfLua oldfiles",
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
                        action = "Lazy",
                    },
                    {
                        icon = icons.misc.update .. "  ",
                        icon_hl = "Identifier",
                        desc = rpad_default("Update plugins"),
                        key = "u",
                        key_hl = key_hl,
                        action = "Lazy update",
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
    end,
}
