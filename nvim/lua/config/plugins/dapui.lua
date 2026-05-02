return {
    src = "https://www.github.com/rcarriga/nvim-dap-ui",
    data = {
        config = function(dapui)
            local dap = require("dap")

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

            -- TODO: Set/unset debug keymaps here instead

            -- dap.listeners.after.event_initialized["dapui_config"] = dapui.open
            dap.listeners.after.event_breakpoint["dapui_config"] = dapui.open
            dap.listeners.before.event_terminated["dapui_config"] = dapui.close
            dap.listeners.before.event_exited["dapui_config"] = dapui.close
        end,
    },
}
