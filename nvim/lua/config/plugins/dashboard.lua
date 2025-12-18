return {
    "nvimdev/dashboard-nvim",
    config = function()
        local icons = require("config.icons")
        local dashboard = require("dashboard")
        local ascii = require("config.images.ascii")
        local key_hl = "Number"

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

        dashboard.setup({
            theme = "doom",
            config = {
                vertical_center = true,
                header = ascii[math.random(1, #ascii)],
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
                        icon = icons.misc.package .. "  ",
                        icon_hl = "Identifier",
                        desc = rpad_default("Plugins"),
                        key = "p",
                        key_hl = key_hl,
                        action = "Lazy",
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
