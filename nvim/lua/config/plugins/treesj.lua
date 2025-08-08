return {
    "Wansmer/treesj", 
    config = function()
        local treesj = require("treesj")
        local lang_utils = require("treesj.langs.utils")
        local map = require("config.map")

        -- TODO: Use this as a fallback if there is no .eslintrc to parse or the rules are not set
        local js_ts_common_override = {
            split = {
                last_separator = false,
            },
        }

        local js_ts_array_override = vim.tbl_extend("force", {
            join = {
                space_in_brackets = false,
            },
        }, js_ts_common_override)

        local js_ts_dict_override = vim.tbl_extend("force", {
            join = {
                space_in_brackets = true,
            },
        }, js_ts_common_override)

        treesj.setup({
            use_default_keymaps = false,
            max_join_length = 9999,
            langs = {
                javascript = {
                    array = lang_utils.set_preset_for_list(js_ts_array_override),
                    object = lang_utils.set_preset_for_dict(js_ts_dict_override),
                },
                typescript = {
                    array = lang_utils.set_preset_for_list(js_ts_array_override),
                    object = lang_utils.set_preset_for_dict(js_ts_dict_override),
                    parenthesized_expression = lang_utils.set_preset_for_args(),
                },
            },
        })

        map.n("gm", treesj.toggle, "Split or join treesitter node")
    end,
}
