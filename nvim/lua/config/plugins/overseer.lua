return {
    "stevearc/overseer.nvim",
    config = function()
        local map = require("config.map")
        local overseer = require("overseer")

        overseer.setup({
            direction = "left",
            bindings = {
                ["<c-h>"] = false,
                ["<c-j>"] = false,
                ["<c-k>"] = false,
                ["<c-l>"] = false,
            }
        })

        vim.api.nvim_create_user_command("OverseerRestartLast", function()
            local tasks = overseer.list_tasks({ recent_first = true })

            if vim.tbl_isempty(tasks) then
                vim.notify("No tasks found", vim.log.levels.WARN)
            else
                overseer.run_action(tasks[1], "restart")
            end
        end, {})

        map.n.leader("or", "<cmd>OverseerRun<cr>", "Run a task using overseer")
        map.n.leader("oo", "<cmd>OverseerToggle<cr>", "Toggle the overseer window")
        map.n.leader("ol", "<cmd>OverseerRestartLast<cr>", "Restart the last task if any")

        ---@param options overseer.SearchParams
        ---@return boolean
        ---@diagnostic disable-next-line: unused-local
        local function has_package_json_root(options)
            return vim.fs.root(0, { "package.json" }) ~= nil
        end

        overseer.register_template({
            name = "npm run all",
            ---@diagnostic disable-next-line: unused-local
            builder = function(params)
                return {
                    cmd = { vim.env.SHELL },
                    args = { "-c", "npa all -c" },
                }
            end,
            desc = "run npm build, test, and lint scripts",
            tags = { overseer.TAG.BUILD },
            condition = {
                filetype = { "javascript", "typescript" },
                callback = has_package_json_root,
            },
        })

        overseer.register_template({
            name = "npm install",
            ---@diagnostic disable-next-line: unused-local
            builder = function(params)
                return {
                    cmd = { vim.env.SHELL },
                    args = { "-c", "npm i" },
                }
            end,
            desc = "Install packages",
            tags = { overseer.TAG.BUILD },
            condition = {
                filetype = { "javascript", "typescript", "json" },
                callback = function(options)
                    if options.filetype == "json" then
                        return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t") == "package.json"
                    end

                    return has_package_json_root(options)
                end
            },
        })

        overseer.register_template({
            name = "Ninja",
            ---@diagnostic disable-next-line: unused-local
            builder = function(params)
                return {
                    cmd = { "ninja" },
                }
            end,
            desc = "build a C/C++ project with ninja",
            tags = { overseer.TAG.BUILD },
            condition = {
                filetype = { "c", "cpp" },
                callback = function()
                    return vim.fn.executable("ninja") == 1
                end,
            },
        })
    end,
}
