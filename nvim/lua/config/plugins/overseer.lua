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
    end,
}
