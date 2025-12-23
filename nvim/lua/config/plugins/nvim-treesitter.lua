return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    config = function()
        local nvts = require("nvim-treesitter")
        local map = require("config.map")
        local ts = require("config.treesitter.utils")

        nvts.setup()

        nvts.install({
            "bash",
            "cpp",
            "fish",
            "gitcommit",
            "git_rebase",
            "javascript",
            "json",
            "lua",
            "markdown",
            "markdown_inline",
            "python",
            "sql",
            "typescript",
            "vim",
            "vimdoc",
            "yaml",
        })

        map.n.leader("fs", function()
            local node = ts.get_enclosing_top_level_function(vim.treesitter.get_node())

            if not node then
                return
            end

            -- Assume that the "name" child node is the function identifier/name
            local nodes = node:field("name")
            local function_name = #nodes > 0 and nodes[1] or node
            local lnum, col, _ = function_name:start()

            vim.fn.cursor(lnum + 1, col + 1)
        end, "Navigate to the enclosing top-level function")

        map.n.leader("fe", function()
            local node = ts.get_enclosing_top_level_function(vim.treesitter.get_node())

            if node ~= nil then
                local result = ts.get_end_of_enclosing_top_level_function(node)

                if result then
                    vim.fn.cursor(result.lnum, result.col)
                else
                    vim.notify("Could not find end of enclosing top-level function", vim.log.levels.ERROR)
                end
            end
        end, "Navigate to the end of the enclosing top-level function")

        map.n.leader("fz", function()
            local node = ts.get_enclosing_top_level_function(vim.treesitter.get_node())

            if not node then
                return
            end

            -- Assume that the "name" child node is the function identifier/name
            local nodes = node:field("name")
            local function_name = #nodes > 0 and nodes[1] or node
            local start_lnum, start_col, _ = function_name:start()
            local end_lnum, _, _ = node:end_()
            local win_height = vim.api.nvim_win_get_height(0)
            local func_height = end_lnum - start_lnum

            vim.print(func_height)
            vim.print(win_height)

            if func_height > win_height then
                -- Cannot center, default to jumping to start of function
                vim.fn.cursor(start_lnum + 1, start_col + 1)
                return
            end

            local center_lnum = start_lnum + func_height / 2

            vim.fn.cursor(center_lnum + 1, 0)
            vim.cmd.normal("zz")
        end, "Center current function if smaller than current window")

        -- Unmap incremental selection inside the command-line window
        vim.api.nvim_create_autocmd("CmdwinEnter", { command = "silent! nunmap <buffer> <cr>" })
    end,
}
