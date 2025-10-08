return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-neotest/neotest-plenary",
            "nvim-neotest/neotest-jest",
            "MisanthropicBit/neotest-busted",
        },
        config = function()
            local neotest = require("neotest")

            local icons = require("config.icons")
            local map = require("config.map")

            local filter_dirs = { "bin", "mysqldata", "node_modules", "build", "cache", "__snapshots__", "coverage" }

            vim.diagnostic.config({}, vim.api.nvim_create_namespace("neotest"))

            ---@return string
            local function get_cwd()
                return vim.uv.cwd()
            end

            ---@diagnostic disable-next-line: missing-fields
            neotest.setup({
                icons = {
                    running_animated = icons.animation.updating,
                },
                ---@diagnostic disable-next-line: missing-fields
                summary = {
                    jumpto = "g",
                },
                ---@diagnostic disable-next-line: missing-fields
                discovery = {
                    ---@diagnostic disable-next-line:unused-local
                    filter_dir = function(name, rel_path, root)
                        return not vim.tbl_contains(filter_dirs, name)
                    end,
                },
                adapters = {
                    require("neotest-jest")({
                        jestCommand = function(path)
                            local cwd = get_cwd()

                            if vim.endswith(cwd, "/api") or vim.endswith(cwd, "/mailman") then
                                if path:match(".it.[tj]s$") then
                                    return "npm run test:integration -- "
                                elseif path:match(".render.test.ts$") then
                                    return "npm run test:render --"
                                else
                                    return "npm run test:unit --"
                                end
                            end

                            return "npm test --"
                        end,
                        jest_test_discovery = true,
                        cwd = get_cwd,
                        isTestFile = function(file_path)
                            if require("neotest-jest.jest-util").defaultIsTestFile(file_path) then
                                return true
                            end

                            local ext = vim.fn.fnamemodify(file_path, ":e:e")

                            return ext == "it.ts" and require("neotest-jest.jest-util").hasJestDependency(file_path)
                        end,
                        strategy_config = function(default_strategy, _)
                            default_strategy["resolveSourceMapLocations"] = {
                                "${workspaceFolder}/**",
                                "!**/node_modules/**",
                            }

                            return default_strategy
                        end,
                        -- extension_test_file_match = require("neotest-jest.util").create_test_file_extensions_matcher(
                        --     { "test", "it" },
                        --     { "js", "ts" }
                        -- ),
                    }),
                    require("neotest-busted"),
                },
                ---@diagnostic disable-next-line: missing-fields
                quickfix = {
                    open = false,
                },
                ---@diagnostic disable-next-line: missing-fields
                output = {
                    open_on_run = false,
                },
            })

            map.n.leader("tt", neotest.run.run, "Run the test under the cursor")
            ---@diagnostic disable-next-line: missing-fields
            map.n.leader("tu", function()
                ---@diagnostic disable-next-line: missing-fields
                neotest.run.run({
                    extra_args = { "--updateSnapshot" },
                })
            end, "Run the test under the cursor and update snapshots")
            map.n.leader("tU", function()
                neotest.run.run({ vim.fn.expand("%"), extra_args = { "--updateSnapshot" } })
            end, "Run all tests in the current file and update snapshots")
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
                ---@diagnostic disable-next-line: missing-fields
                neotest.run.run({ strategy = "dap" })
            end, "Run the test under the cursor using dap")
            map.n.leader("tS", function()
                neotest.run.run({ suite = true })
            end, "Run entire test suite")
        end,
    },
}
