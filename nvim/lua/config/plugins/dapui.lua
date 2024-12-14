return {
    "rcarriga/nvim-dap-ui";
    dependencies = {},
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        dapui.setup({
            layouts = {
                {
                    elements = {
                        "breakpoints",
                        "stacks",
                        "watches",
                        "scopes",
                    },
                    size = 40,
                    position = "left",
                },
                {
                    elements = {
                        "repl",
                        "console",
                    },
                    size = 0.25,
                    position = "bottom",
                },
            },
            controls = {
                enabled = false,
            },
            floating = {
                border = "rounded",
            },
        })

        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close
    end,
}
