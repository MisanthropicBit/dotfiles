local map = require("config.map")
local icons = require("config.icons")

local dap = require("dap")
local dap_widgets = require("dap.ui.widgets")
local debugging = icons.debugging

local fzf_lua_loaded, fzf_lua_core = pcall(require, "fzf-lua.core")

local select_executable_prompt = "Select executable " .. icons.misc.prompt

local function select_executable()
    return vim.fn.input(select_executable_prompt, vim.fn.getcwd() .. "/", "file")
end

if not fzf_lua_loaded then
    select_executable = function()
        fzf_lua_core.fzf_exec("fd --type executable", {
            prompt = select_executable_prompt,
            cwd = vim.fn.getcwd(),
            winopts = { width = 0.6, height = 0.5 },
            fzf_opts = { ["--pointer"] = debugging.breakpoint },
        })
    end
end

local function conditional_breakpoint()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition " .. icons.misc.prompt))
end

map.leader("n", "db", dap.toggle_breakpoint, "Toggle a breakpoint")
map.leader("n", "dB", conditional_breakpoint, "Set a conditional breakpoint")
map.leader("n", "dd", dap.clear_breakpoints, "Clear all breakpoints")
map.leader("n", "dc", dap.continue, "Continue debugging")
map.leader("n", "do", dap.step_over, "Step over")
map.leader("n", "di", dap.step_into, "Step into")
map.leader("n", "du", dap.step_out, "Step out of")
map.leader("n", "dr", dap.repl.open, "Open the REPL for debugging")
map.leader("n", "dh", dap_widgets.hover, "Inspect value of expression under cursor when debugging")
map.leader("n", "dt", dap.terminate, "Terminate/stop debugging")

-- Adapters
require("dap-vscode-js").setup({
    debugger_path = vim.fn.expand("~/vscode-js-debug"),
    adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
    log_file_path = "(stdpath cache)/dap_vscode_js.log",
    log_file_level = false,
    log_console_level = vim.log.levels.ERROR,
})

dap.adapters.codelldb = {
    type = "server",
    port = "${port}",
    executable = {
        command = vim.fs.normalize("~/packages/codelldb/extension/adapter/codelldb"),
        args = { "--port", "${port}" },
    },
}

-- Configurations
for _, language in ipairs({ "typescript", "javascript" }) do
    dap.configurations[language] = {
        {
            type = "pwa-node",
            request = "launch",
            name = "Launch server",
            runtimeExecutable = "npm",
            runtimeArgs = { "run", "start-env" },
            skipFiles = { "node_modules/**" },
            console = "integratedTerminal",
            cwd = "${workspaceFolder}",
        },
    }
end

dap.configurations.cpp = {
    {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = select_executable,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = function()
            local args = {}
            local args_string = vim.fn.input("Program arguments " .. icons.misc.prompt)

            for word in args_string:gmatch("%S+") do
                table.insert(args, word)
            end

            return args
        end,
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
