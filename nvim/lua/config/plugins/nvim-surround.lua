return {
    "kylechui/nvim-surround",
    config = function()
        local surround = require("nvim-surround")
        local defaults = require("nvim-surround.config").default_opts
        local map = require("config.map")

        surround.setup({
            surrounds = {
                ["8"] = defaults.surrounds[")"],
                ["9"] = defaults.surrounds["{"],
            },
        })

        map.n("g'", "<cmd>normal ysiw'<cr>")
        -- map.n("g´", "<cmd>normal ysiw`<cr>>")
        map.n("g0", "<cmd>normal ysiw\"<cr>")
        map.n("g8", "<cmd>normal ysiw)<cr>")
        map.n("g9", "<cmd>normal ysiw]<cr>")

        local supported_node_types = {
            "string_fragment",
            "string",
            "template_string",
        }

        local quote_toggle_map = {
            ["'"] = '"',
            ['"'] = "`",
            ["`"] = "'",
        }

        map.n("gns", function()
            local ts_utils = require("nvim-treesitter.ts_utils")
            local node = ts_utils.get_node_at_cursor()

            if not node or not vim.list_contains(supported_node_types, node:type()) then
                return
            end

            if node:type() == "string_fragment" then
                node = node:parent()
            end

            local text = vim.treesitter.get_node_text(node, vim.api.nvim_get_current_buf())
            local quote = text:sub(1, 1)
            local next_quote = quote_toggle_map[quote]

            local oldpos = vim.api.nvim_win_get_cursor(0)
            vim.cmd.normal(([[cs%s%s]]):format(quote, next_quote))
            vim.api.nvim_win_set_cursor(0, oldpos)
        end, "Change to [n]ext [s]urround")
    end,
}
