---@type config.PluginSpec
return {
    src = "https://www.github.com/rcarriga/nvim-dap-ui",
    version = "f5b6673f374626515401c5bc51b005f784a4f252",
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

            vim.api.nvim_create_user_command("DapUiOpen", dapui.open, {})
            vim.api.nvim_create_user_command("DapUiClose", dapui.close, {})
        end,
    },
}
