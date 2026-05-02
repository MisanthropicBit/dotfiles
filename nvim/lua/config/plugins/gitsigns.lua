return {
    src = "https://www.github.com/lewis6991/gitsigns.nvim",
    data = {
        config = function(gitsigns)
            local map = require("config.map")

            gitsigns.setup({
                signs = {
                    delete = "",
                },
                signs_staged = {
                    delete = "",
                },
                sign_priority = 1001,
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

                            move_func()

                            return "<ignore>"
                        end, {
                            buffer = buffer,
                            expr = true,
                        })
                    end

                    move("gj", "]c", function()
                        gs.nav_hunk("next", { wrap = true, foldopen = true }, function()
                            vim.cmd.normal("zz")
                        end)
                    end)

                    move("gk", "[c", function()
                        gs.nav_hunk("prev", { wrap = true, foldopen = true }, function()
                            vim.cmd.normal("zz")
                        end)
                    end)

                    map.n.leader("hv", gs.preview_hunk)
                    map.n.leader("hu", gs.reset_hunk)
                    map.n.leader("hs", gs.stage_hunk)
                    map.n.leader("hd", gs.diffthis)
                    map.n.leader("hr", gs.reset_buffer)
                    map.n.leader("hq", gs.setqflist)

                    map.set({ "o", "x" }, "ah", "<cmd>Gitsigns select_hunk<cr>")
                end,
            })
        end,
    },
}
