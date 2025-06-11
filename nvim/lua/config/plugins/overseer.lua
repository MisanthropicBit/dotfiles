return {
    "stevearc/overseer.nvim",
    config = function()
        local map = require("config.map")
        local overseer = require("overseer")

        overseer.setup({
            direction = "left",
            bindings = {
                ["<c-h>"] = false,
                ["<c-j>"] = false,
                ["<c-k>"] = false,
                ["<c-l>"] = false,
            }
        })

        map.n.leader("or", "<cmd>OverseerRun<cr>", "Run a task using overseer")
        map.n.leader("oo", "<cmd>OverseerToggle<cr>", "Toggle the overseer window")

        overseer.register_template({
            name = "npm run all",
            ---@diagnostic disable-next-line: unused-local
            builder = function(params)
                return {
                    cmd = { vim.env.SHELL },
                    args = { "-c", "npa all -c" },
                }
            end,
            desc = "run npm build, test, and lint scripts",
            tags = { overseer.TAG.BUILD },
            condition = {
                filetype = { "javascript", "typescript" },
                callback = function()
                    return vim.fs.root(0, { "package.json" }) ~= nil
                end,
            }
        })

        overseer.register_template({
            name = "Ninja",
            ---@diagnostic disable-next-line: unused-local
            builder = function(params)
                return {
                    cmd = { "ninja" },
                }
            end,
            desc = "build a C/C++ project with ninja",
            tags = { overseer.TAG.BUILD },
            condition = {
                filetype = { "c", "cpp" },
                callback = function()
                    return vim.fn.executable("ninja") == 1
                end,
            }
        })
    end,
}
