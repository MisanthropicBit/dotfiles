local neotest = require("neotest")

local icons = require("config.icons")
local map = require("config.map")

vim.diagnostic.config({}, vim.api.nvim_create_namespace("neotest"))

neotest.setup({
    icons = {
        running = icons.test.running,
        running_animated = icons.animation.updating,
        passed = icons.test.passed,
        failed = icons.test.failed,
        skipped = icons.test.skipped,
        unknown = icons.test.unknown,
    },
    ---@diagnostic disable-next-line:unused-local
    filter_dir = function(name, rel_path, root)
        return name ~= "node_modules" and name ~= "build"
    end,
    adapters = {
        require("neotest-jest")({
            jestCommand = "npm test --",
            cwd = function()
                return vim.fn.getcwd()
            end,
        }),
        require("neotest-busted"),
    },
    quickfix = {
        open = false,
    },
    output = {
        open_on_run = false,
    },
})

map.n.leader("tt", neotest.run.run, "Run the test under the cursor")
map.n.leader("tl", neotest.run.run_last, "Run the last run test")
map.n.leader("tf", function()
    neotest.run.run(vim.fn.expand("%"))
end, "Run all tests in the current file")
map.n.leader("ts", neotest.summary.toggle, "Toggle test summary")
map.n.leader("tp", neotest.jump.prev, "Jump to previous test")
map.n.leader("tn", neotest.jump.next, "Jump to next test")
map.n.leader("tP", function()
    neotest.jump.prev({ status = "failed" })
end, "Jump to previous failed test")
map.n.leader("tN", function()
    neotest.jump.next({ status = "failed" })
end, "Jump to next failed test")
map.n.leader("to", function()
    neotest.output.open({ enter = true })
end, "Open test output")
map.n.leader("tL", function()
    neotest.output.open({ last_run = true })
end, "Open test output for the last run test")
map.n.leader("tO", neotest.output_panel.toggle, "Toggle the test output panel")
map.n.leader("td", function()
    neotest.run.run({ strategy = "dap" })
end, "Run the test under the cursor using dap")
map.n.leader("tS", function()
    neotest.run.run({ suite = true })
end, "Run entire test suite")
