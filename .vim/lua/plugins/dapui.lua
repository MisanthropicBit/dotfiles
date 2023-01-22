local dap = require('dap')
local dapui = require('dapui')

dapui.setup{
    layouts = {
        {
            elements = {
                'scopes',
                'watches',
                'stacks',
                'breakpoints',
            },
            size = 40,
            position = 'left',
        },
        {
            elements = {
                'repl',
                'console',
            },
            size = 0.25,
            position = 'bottom'
        }
    },
    controls = {
        enabled = false,
    },
    floating = {
        border = 'rounded',
    },
}

dap.listeners.after.event_initialized['dapui_config'] = function()
    dapui.open()
    vim.notify('Initialized successfully', 0, { mac = true, title = 'nvim-dap-ui' })
end

dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close
