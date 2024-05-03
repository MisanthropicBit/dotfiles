local neotest = require("neotest")

local icons = require("config.icons")
local map = require("config.map")

vim.diagnostic.config({}, vim.api.nvim_create_namespace("neotest"))

---@return string
local function get_cwd()
    return vim.fn.getcwd()
end

---@param path string
---@return boolean
local function is_integration_test(path)
    return path:match(".it.[tj]s$")
end

---@diagnostic disable-next-line: missing-fields
neotest.setup({
    icons = {
        running_animated = icons.animation.updating,
    },
    summary = {
        jumpto = "g",
    },
    ---@diagnostic disable-next-line:unused-local
    filter_dir = function(name, rel_path, root)
        return name ~= "node_modules" and name ~= "build"
    end,
    adapters = {
        require("neotest-jest")({
            jestCommand = function(path)
                local cwd = get_cwd()

                if vim.endswith(cwd, 'mailman') then
                    local project = is_integration_test(path) and [[\"integration tests\"]] or [[\"unit tests\"]]

                    return "npm test -- --selectProjects " .. project
                end

                return "npm test --"
            end,
            cwd = get_cwd,
        }),
        require("neotest-mocha")({
            command = function(path)
                local test_type = is_integration_test(path) and "integration" or "unit"

                return "npm run test:" .. test_type .. " -- "
            end,
            command_args = function(context)
                return {
                    "--reporter=" .. vim.fs.normalize(
                        "~/repos/mocha-multi-reporter/build/dist/src/mocha-multi-reporter.js"
                    ),
                    "--reporter-options=reporters=spec:json",
                    "--reporter-options=json:output=" .. context.results_path,
                    "--grep=" .. context.test_name_pattern,
                    "--colors",
                    context.path,
                }
            end,
            is_test_file = require("neotest-mocha.util").create_test_file_extensions_matcher(
                { "test", "it" },
                { "js", "ts" }
            ),
            cwd = get_cwd,
        }),
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
