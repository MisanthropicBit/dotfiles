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

dap.defaults.fallback.terminal_win_cmd = 'tabnew'
dap.defaults.fallback.external_terminal = {
    command = vim.fn.expand('$SHELL'),
    args = { '-c' },
}
dap.defaults.fallback.force_external_terminal = true

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
            env = {
                LOG_LEVEL = 'WARNING'
            },
        },
    }
end

local debugging = icons.debugging
vim.fn.sign_define('DapBreakpoint', { text = debugging.breakpoint, texthl = 'DiagnosticError', numhl = 'DiagnosticError' })
vim.fn.sign_define('DapBreakpointCondition', { text = debugging.breakpoint_condition })
vim.fn.sign_define('DapLogPoint', { text = debugging.log_point })
vim.fn.sign_define('DapStopped', { text = debugging.cursor, texthl = 'ErrorMsg', culhl = 'ErrorMsg' })
vim.fn.sign_define('DapBreakpointRejected', { text = debugging.rejected })

-- Wait for a local server's readiness endpoint to respond with 200
local function wait_for_server(address)
    if vim.fn.executable('curl') ~= 1 then
        return
    end

    local ping_cmd = string.format("curl --silent --write-out '%%{response_code}' --output /dev/null %s", address)
    local timer = vim.loop.new_timer()

    -- Wait 2 seconds then start pinging the server every other second until it
    -- responds or we have tried 20 times
    local tries = 0

    timer:start(2 * 1000, 2 * 1000, vim.schedule_wrap(function()
        if tries >= 20 then
            return
        end

        -- vim.fn.system('nc -z 127.0.0.1 3100')
        local response_code = vim.fn.system(ping_cmd)

        if vim.v.shell_error == 0 and response_code == '200' then
            vim.notify('Server is ready', 0, { mac = true, title = 'nvim-dap' })
            timer:stop()
            timer:close()
        end

        tries = tries + 1

        if tries == 20 then
            vim.notify('Timed out waiting for server', 0, { mac = true, title = 'nvim-dap' })
            timer:stop()
            timer:close()
        end
    end))
end

dap.listeners.after.event_initialized['dap'] = function(session, event)
    -- vim.pretty_print(event)
    -- vim.pretty_print(session.config.name)

    if session.config.name == launch_server_config_name then
        wait_for_server('http://127.0.0.1:3100/readiness')
    end
end
-- 
