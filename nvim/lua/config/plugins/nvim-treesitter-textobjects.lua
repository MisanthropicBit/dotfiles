return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    config = function()
        local map = require("config.map")
        local ts_textobjects = require("nvim-treesitter-textobjects")

        ts_textobjects.setup({
            select = {
                lookahead = true,
                selection_modes = {
                    ["@parameter.outer"] = "v",
                    ["@function.outer"] = "V",
                },
            },
            move = {
                set_jumps = true,
            },
        })

        -- Text-object selections
        local text_objects_select = require("nvim-treesitter-textobjects.select")

        map.set({ "x", "o" }, "af", function()
            text_objects_select.select_textobject("@function.outer", "textobjects")
        end)

        map.set({ "x", "o" }, "if", function()
            text_objects_select.select_textobject("@function.inner", "textobjects")
        end)

        map.set({ "x", "o" }, "aa", function()
            text_objects_select.select_textobject("@parameter.outer", "textobjects")
        end)

        map.set({ "x", "o" }, "ia", function()
            text_objects_select.select_textobject("@parameter.inner", "textobjects")
        end)

        map.set({ "x", "o" }, "an", function()
            text_objects_select.select_textobject("@number", "textobjects")
        end)

        map.set({ "x", "o" }, "in", function()
            text_objects_select.select_textobject("@number", "textobjects")
        end)

        map.set({ "x", "o" }, "ag", function()
            text_objects_select.select_textobject("@comment.outer", "textobjects")
        end)

        map.set({ "x", "o" }, "ig", function()
            text_objects_select.select_textobject("@comment.inner", "textobjects")
        end)

        map.set({ "x", "o" }, "ac", function()
            text_objects_select.select_textobject("@conditional.outer", "textobjects")
        end)

        map.set({ "x", "o" }, "ic", function()
            text_objects_select.select_textobject("@conditional.inner", "textobjects")
        end)

        map.set({ "x", "o" }, "al", function()
            text_objects_select.select_textobject("@loop.outer", "textobjects")
        end)

        map.set({ "x", "o" }, "il", function()
            text_objects_select.select_textobject("@loop.inner", "textobjects")
        end)

        -- Text-object swaps
        local text_objects_swap = require("nvim-treesitter-textobjects.swap")

        map.n.leader("ah", function()
            text_objects_swap.swap_previous("@parameter.inner")
        end)

        map.n.leader("al", function()
            text_objects_swap.swap_next("@parameter.inner")
        end)

        -- Text-object moves
        local text_objects_move = require("nvim-treesitter-textobjects.move")

        map.n.leader("fn", function()
            text_objects_move.goto_next_start("@function.outer", "textobjects")
        end)

        map.n.leader("fp", function()
            text_objects_move.goto_previous_start("@function.outer", "textobjects")
        end)

        map.n.leader("an", function()
            text_objects_move.goto_next_start("@parameter.inner", "textobjects")
        end)

        map.n.leader("ap", function()
            text_objects_move.goto_previous_start("@parameter.inner", "textobjects")
        end)

        -- Repeatable moves
        local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

        local function run_and_center(func)
            return function()
                func()
                vim.cmd.normal("zz")
            end
        end

        map.set({ "n", "x", "o" }, "-", run_and_center(ts_repeat_move.repeat_last_move_next))
        map.set({ "n", "x", "o" }, "_", run_and_center(ts_repeat_move.repeat_last_move_previous))
    end
}
