return {
    "lewis6991/gitsigns.nvim",
    config = function()
        local map = require("config.map")

        require("gitsigns").setup({
            numhl = true,
            on_attach = function(buffer)
                local gs = package.loaded.gitsigns

                ---@param lhs string
                ---@param diff_rhs string
                ---@param move_func fun(): nil
                local function move(lhs, diff_rhs, move_func)
                    map.n(lhs, function()
                        if vim.wo.diff then
                            return diff_rhs
                        end

                        vim.schedule(function()
                            move_func()
                            vim.cmd.normal("zz")
                        end)

                        return "<ignore>"
                    end, {
                    buffer = buffer,
                    expr = true,
                })
            end

            move("gj", "]c", gs.next_hunk)
            move("gk", "[c", gs.prev_hunk)

            map.n.leader("hv", gs.preview_hunk)
            map.n.leader("hu", gs.reset_hunk)
            map.n.leader("hU", gs.undo_stage_hunk)
            map.n.leader("hs", gs.stage_hunk)
            map.n.leader("hd", gs.diffthis)

            map.set({ "o", "x" }, "ah", "<cmd>Gitsigns select_hunk<cr>")
        end
    })
    end,
}
