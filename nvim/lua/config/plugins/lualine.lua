return {
    "nvim-lualine/lualine.nvim",
    dependencies = "stevearc/overseer.nvim",
    config = function()
        local lualine = require("lualine")

        local icons = require("config.icons")
        local lsp_utils = require("config.lsp.utils")

        local cached_formatted_branch = nil

        ---@return string
        local function get_active_lsps_for_buffer()
            local msg = "No active LSPs"
            local clients = lsp_utils.get_active_clients_for_buffer(vim.api.nvim_get_current_buf())

            if #clients > 0 then
                return table.concat(
                    vim.tbl_map(function(client)
                        return client.name
                    end, clients),
                    ", "
                )
            end

            return msg
        end

        local function format_git_branch(branch)
            -- No need to continuously format the git branch
            if cached_formatted_branch then
                return cached_formatted_branch
            end

            local parts = vim.fn.split(branch, [[\/]], false)
            local head = parts[1]

            local icon = ({
                feature = "",
                bug = "",
                chore = "󰱶",
            })[head]

            if icon then
                cached_formatted_branch = ("%s %s"):format(icon, table.concat(vim.list_slice(parts, 2), "/"))
            else
                cached_formatted_branch = branch
            end

            return cached_formatted_branch
        end

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
            options = {
                theme = "auto",
                section_separators = {
                    left = icons.separators.high_slant_lower_left,
                    right = icons.separators.high_slant_lower_right .. " ",
                },
                extensions = { "fugitive", "nvim-dap-ui" },
            },
            sections = {
                lualine_a = {
                    {
                        "branch",
                        icon = nil, -- { icons.git.logo, align = "left" },
                        fmt = format_git_branch,
                    },
                },
                lualine_b = {
                    {
                        get_active_lsps_for_buffer,
                        icon = icons.lsp.nvim_lsp,
                        cond = conditions.all,
                    },
                },
                lualine_c = {
                    {
                        "vim.g.colors_name",
                        icon = { icons.color.scheme .. " ", align = "left" },
                        cond = conditions.show_for_width,
                    },
                },
                lualine_x = {
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
                lualine_y = {
                    {
                        "progress",
                        cond = conditions.ignore_terminal,
                    },
                },
                lualine_z = {
                    "location",
                    {
                        separator = { right = "" },
                        left_padding = 2,
                        cond = conditions.ignore_terminal,
                    },
                },
            },
        }

        local has_overseer, overseer = pcall(require, "overseer")

        if has_overseer then
            table.insert(layout.sections.lualine_b, {
                "overseer",
                label = "",
                colored = true,
                symbols = {
                    [overseer.STATUS.FAILURE] = icons.test.failed .. " ",
                    [overseer.STATUS.CANCELED] = icons.test.skipped .. " ",
                    [overseer.STATUS.SUCCESS] = icons.test.passed .. " ",
                    [overseer.STATUS.RUNNING] = icons.test.running .. " ",
                },
            })
        end

        lualine.setup(layout)
    end,
}
