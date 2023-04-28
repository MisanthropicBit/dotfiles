local icons = require('icons')
local lsp_common = require('lsp_common')
local lualine = require('lualine')

---@return string
local function get_active_lsp()
    local msg = 'No active lsp'
    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = lsp_common.get_active_clients_for_filetype(buf_ft)

    if #clients > 0 then
        return table.concat(vim.tbl_map(function(client)
            return client.name
        end, clients), ', ')
    end

    return msg
end

local conditions = {
    show_for_width = function()
        return vim.fn.winwidth(0) > 120
    end
}

lualine.setup({
    options = {
        theme = 'auto',
        section_separators = {
            left = '',
            right = '',
        },
        extensions = { 'fugitive', 'nvim-dap-ui' }
    },
    sections = {
        lualine_a = {
            {
                'mode',
                separator = { left = '' },
                right_padding = 3
            },
        },
        lualine_b = {
            {
                'branch',
                icon = { icons.git.logo, align = 'left' },
            },
            {
                'diff',
                colored = true,
                symbols = {
                    added = icons.git.added,
                    modified = icons.git.added,
                    removed = icons.git.added,
                },
            },
        },
        lualine_c = {
            {
                get_active_lsp,
                icon = icons.lsp.nvim_lsp,
                cond = conditions.show_for_width,
            },
            {
                'vim.g.colors_name',
                icon = { icons.color.scheme .. ' ', align = 'left' },
                cond = conditions.show_for_width,
            }
        },
        lualine_x = {
            {
                'filename',
                file_status = true,
                icon = { icons.files.files },
                symbols = {
                    modified = icons.git.added,
                    readonly = icons.files.readonly,
                }
            },
            {
                'fileformat',
                cond = conditions.show_for_width,
            },
            'filetype',
            {
                'filesize',
                cond = conditions.show_for_width,
            },
            {
                'encoding',
                cond = conditions.show_for_width,
            },
        },
        lualine_z = {
            'location',
            {
                separator = { right = '' },
                left_padding = 2
            }
        },
    },
})
