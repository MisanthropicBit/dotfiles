local icons = require('icons')
local map = require('mappings')

local neotest = require('neotest')

vim.diagnostic.config({}, vim.api.nvim_create_namespace('neotest'))

neotest.setup{
    icons = {
        running = icons.test.running,
        running_animated = {'⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'},
        passed = icons.test.passed,
        failed = icons.test.failed,
        skipped = icons.test.skipped,
        unknown = icons.test.unknown,
    },
    ---@diagnostic disable-next-line:unused-local
    filter_dir = function(name, rel_path, root)
        return name ~= 'node_modules' and name ~= 'build'
    end,
    adapters = {
        require('neotest-jest')({
            jestCommand = 'npm test --',
            jestConfigFile = 'jest.config.ts',
            ---@diagnostic disable-next-line:unused-local
            cwd = function(path)
                return vim.fn.getcwd()
            end,
        }),
        require('neotest-plenary'),
    },
    quickfix = {
        open = false,
    },
    output = {
        open_on_run = false,
    }
}

map.leader('n', 'tt', neotest.run.run, 'Run the test under the cursor')
map.leader('n', 'tl', neotest.run.run_last, 'Run the last run test')
map.leader('n', 'tf', function() neotest.run.run(vim.fn.expand('%')) end, 'Run all tests in file')
map.leader('n', 'ts', neotest.summary.toggle, 'Toggle test summary')
map.leader('n', 'tp', neotest.jump.prev, 'Jump to previous test')
map.leader('n', 'tn', neotest.jump.next, 'Jump to next test')
map.leader('n', 'tP', function() neotest.jump.prev({ status = 'failed' }) end, 'Jump to previous failed test')
map.leader('n', 'tN', function() neotest.jump.next({ status = 'failed' }) end, 'Jump to next failed test')
map.leader('n', 'to', function() neotest.output.open({ enter = true }) end, 'Open test output')
map.leader('n', 'tL', function() neotest.output.open({ last_run = true }) end, 'Open test output for the last run test')
map.leader('n', 'tO', neotest.output_panel.toggle, 'Toggle the test output panel')
map.leader('n', 'td', function() neotest.run.run({ strategy = 'dap' }) end, 'Run the test under the cursor using dap')
map.leader('n', 'tS', function() neotest.run.run({ suite = true }) end, 'Run entire test suite')
