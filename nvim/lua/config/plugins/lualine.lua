return {
    src = "https://www.github.com/nvim-lualine/lualine.nvim",
    data = {
        config = function(lualine)
            local icons = require("config.icons")
            local git = require("config.utils.git")

            local conditions = {
                show_for_width = function()
                    return vim.fn.winwidth(0) > 100
                end,
                ignore_terminal = function()
                    return vim.bo.buftype ~= "terminal"
                end,
            }

            conditions.all = function()
                return conditions.show_for_width() and conditions.ignore_terminal()
            end

            local layout = {
                sections = {
                    lualine_a = {
                        {
                            git.current_repository,
                            icon = { icons.files.folder, align = "left" },
                        },
                    },
                    lualine_b = {
                        {
                            "branch",
                            icon = { icons.git.logo, align = "left" },
                        },
                    },
                    lualine_c = {
                        {
                            "lsp_status",
                            icon = icons.lsp.nvim_lsp,
                            symbols = {
                                spinner = icons.animation.updating,
                                done = icons.test.passed,
                            },
                        },
                        "winmove",
                        "run",
                    },
                    lualine_x = {
                        {
                            "vim.g.colors_name",
                            icon = { icons.color.scheme .. " ", align = "left" },
                            cond = conditions.show_for_width,
                        },
                    },
                    lualine_y = {
                        {
                            "fileformat",
                            cond = conditions.all,
                        },
                        {
                            "filesize",
                            cond = conditions.all,
                        },
                        {
                            "encoding",
                            cond = conditions.all,
                        },
                        "%b/0x%B",
                    },
                    lualine_z = {
                        {
                            "location",
                            left_padding = 2,
                            cond = conditions.ignore_terminal,
                        },
                        {
                            "progress",
                            cond = conditions.ignore_terminal,
                        },
                    },
                },
                options = {
                    theme = "auto",
                    section_separators = {
                        left = icons.separators.high_slant_lower_left .. " ",
                        right = icons.separators.high_slant_lower_right .. " ",
                    },
                    extensions = { "fugitive", "nvim-dap-ui", "quickfix", "oil" },
                },
            }

            lualine.setup(layout)
        end,
    },
}
