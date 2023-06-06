local map = require('mappings')
local icons = require('icons')

local dap = require('dap')
local dap_widgets = require('dap.ui.widgets')

local function conditional_breakpoint()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
end

map.leader('n', 'db', dap.toggle_breakpoint, { desc = 'Toggle a breakpoint' })
map.leader('n', 'dB', conditional_breakpoint, { desc = 'Set a conditional breakpoint' })
map.leader('n', 'dc', dap.continue, { desc = 'Continue debugging' })
map.leader('n', 'do', dap.step_over, { desc = 'Step over' })
map.leader('n', 'di', dap.step_into, { desc = 'Step into' })
map.leader('n', 'du', dap.step_out, { desc = 'Step out of' })
map.leader('n', 'dr', dap.repl.open, { desc = 'Open the REPL for debugging' })
map.leader('n', 'dd', dap_widgets.hover, { desc = 'Inspect value of expression under cursor when debugging' })
map.leader('n', 'dt', dap.terminate, { desc = 'Terminate/stop debugging' })

require('dap-vscode-js').setup{
    debugger_path = vim.fn.expand('~/vscode-js-debug'),
    adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
    log_file_path = '(stdpath cache)/dap_vscode_js.log',
    log_file_level = false,
    log_console_level = vim.log.levels.ERROR,
}

local launch_server_config_name = 'Launch server'

for _, language in ipairs({ 'typescript', 'javascript' }) do
    dap.configurations[language] = {
        {
            type = 'pwa-node',
            request = 'launch',
            name = launch_server_config_name,
            runtimeExecutable = 'npm',
            runtimeArgs = { 'run', 'start-env' },
            skipFiles = { 'node_modules/**' },
            console = 'integratedTerminal',
            cwd = '${workspaceFolder}',
        },
    }
end

local debugging = icons.debugging
vim.fn.sign_define('DapBreakpoint', { text = debugging.breakpoint, texthl = 'DiagnosticError', numhl = 'DiagnosticError' })
vim.fn.sign_define('DapBreakpointCondition', { text = debugging.breakpoint_condition })
vim.fn.sign_define('DapLogPoint', { text = debugging.log_point })
vim.fn.sign_define('DapStopped', { text = debugging.cursor, texthl = 'ErrorMsg', culhl = 'ErrorMsg' })
vim.fn.sign_define('DapBreakpointRejected', { text = debugging.rejected })
