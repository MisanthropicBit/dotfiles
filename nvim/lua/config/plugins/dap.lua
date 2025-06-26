return {
    "mfussenegger/nvim-dap",
    config = function()
        local map = require("config.map")
        local icons = require("config.icons")

        local dap = require("dap")
        local dap_widgets = require("dap.ui.widgets")
        local debugging = icons.debugging

        local fzf_lua_loaded, fzf_lua_core = pcall(require, "fzf-lua.core")

        local select_executable_prompt = "Select executable " .. icons.misc.prompt

        local function select_executable()
            return vim.fn.input({
                prompt = select_executable_prompt,
                default = vim.fn.getcwd() .. "/",
                completion = "file",
            })
        end

        if fzf_lua_loaded then
            select_executable = function()
                return coroutine.create(function(dap_run_co)
                    fzf_lua_core.fzf_exec("fd --no-ignore --type executable", {
                        prompt = select_executable_prompt,
                        cwd = vim.fn.getcwd(),
                        winopts = { width = 0.6, height = 0.5 },
                        fzf_opts = { ["--pointer"] = debugging.breakpoint },
                        actions = {
                            ["enter"] = function(selected)
                                coroutine.resume(dap_run_co, selected[1])
                            end,
                        },
                    })
                end)
            end
        end

        local function create_select_args_func(default_args)
            return function()
                return coroutine.create(function(dap_run_co)
                    local _default_args = type(default_args) == "string" and #default_args > 0 and default_args or nil

                    vim.ui.input({
                        prompt = "Program arguments " .. icons.misc.prompt .. " ",
                        default = _default_args,
                        completion = "file",
                        title = " Program arguments",
                    },
                    function(input)
                        local args = {}

                        for word in input:gmatch("%S+") do
                            table.insert(args, word)
                        end

                        coroutine.resume(dap_run_co, args)
                    end)
                end)
            end
        end

        local function conditional_breakpoint()
            dap.set_breakpoint(vim.fn.input("Breakpoint condition " .. icons.misc.prompt))
        end

        map.n.leader("db", dap.toggle_breakpoint, "Toggle a breakpoint")
        map.n.leader("dB", conditional_breakpoint, "Set a conditional breakpoint")
        map.n.leader("dd", dap.clear_breakpoints, "Clear all breakpoints")
        map.n.leader("dc", dap.continue, "Continue debugging")
        map.n.leader("do", dap.step_over, "Step over")
        map.n.leader("di", dap.step_into, "Step into")
        map.n.leader("du", dap.step_out, "Step out of")
        map.n.leader("dr", dap.repl.open, "Open the REPL for debugging")
        map.n.leader("dh", dap_widgets.hover, "Inspect value of expression under cursor when debugging")
        map.n.leader("dx", function()
            dap.terminate()
            dap.disconnect()
        end, "Terminate/stop/exit debugging")

        -- Adapters
        dap.adapters["pwa-node"] = {
            type = "server",
            host = "localhost",
            port = "${port}",
            executable = {
                command = "node",
                args = { vim.fn.expand("~/projects/js-debug/src/dapDebugServer.js"), "${port}" },
            },
        }

        dap.adapters.lldb = {
            type = "executable",
            command = "/usr/local/opt/llvm/bin/lldb-dap",
            name = "lldb",
        }

        dap.adapters["local-lua"] = {
            type = "executable",
            command = "node",
            args = {
                vim.fs.normalize("~/projects/typescript/local-lua-debugger-vscode/extension/debugAdapter.js"),
            },
            enrich_config = function(config, on_config)
                if not config["extensionPath"] then
                    local _config = vim.deepcopy(config)
                    _config.extensionPath = vim.fs.normalize("~/projects/typescript/local-lua-debugger-vscode")
                    on_config(_config)
                else
                    on_config(config)
                end
            end,
        }

        -- Configurations
        for _, language in ipairs({ "typescript", "javascript" }) do
            dap.configurations[language] = {
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch server",
                    runtimeExecutable = "npm",
                    runtimeArgs = create_select_args_func("run start-env"),
                    skipFiles = { "node_modules/**" },
                    console = "integratedTerminal",
                    cwd = "${workspaceFolder}",
                },
            }
        end

        dap.configurations.cpp = {
            {
                name = "Debug with lldb",
                type = "lldb",
                request = "launch",
                program = select_executable,
                cwd = "${workspaceFolder}",
                stopOnEntry = false,
                args = create_select_args_func(),
            }
        }

        dap.configurations.lua = {
            {
                name = "Current file (local-lua-dbg, lua)",
                type = "local-lua",
                request = "launch",
                cwd = "${workspaceFolder}",
                program = {
                    lua = "lua5.1",
                    file = "${file}",
                },
                args = {},
            },
        }

        -- Signs
        vim.fn.sign_define(
            "DapBreakpoint",
            { text = debugging.breakpoint, texthl = "DiagnosticError", numhl = "DiagnosticError" }
        )
        vim.fn.sign_define("DapBreakpointCondition", { text = debugging.breakpoint_condition })
        vim.fn.sign_define("DapLogPoint", { text = debugging.log_point })
        vim.fn.sign_define("DapStopped", { text = debugging.cursor, texthl = "ErrorMsg", culhl = "ErrorMsg" })
        vim.fn.sign_define("DapBreakpointRejected", { text = debugging.rejected })
    end,
}
