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
        chore = "󰱶"
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
        return vim.fn.winwidth(0) > 120
    end,
    ignore_terminal = function()
        return vim.bo.buftype ~= "terminal"
    end,
}

conditions.all = function()
    return conditions.show_for_width() and conditions.ignore_terminal()
end

lualine.setup({
    options = {
        theme = "auto",
        section_separators = {
            left = "",
            right = "",
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
            {
                "diff",
                colored = true,
                symbols = {
                    added = icons.git.added,
                    modified = icons.git.added,
                    removed = icons.git.added,
                },
                cond = conditions.ignore_terminal,
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
                "filename",
                file_status = true,
                icon = { icons.files.files },
                symbols = {
                    modified = icons.git.added,
                    readonly = icons.files.readonly,
                },
            },
            {
                "fileformat",
                cond = conditions.all,
            },
            "filetype",
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
})
