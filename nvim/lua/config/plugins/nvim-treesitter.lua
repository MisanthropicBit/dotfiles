return {
    "nvim-treesitter/nvim-treesitter",
    config = function()
        local map = require("config.map")
        local ts = require("config.treesitter.utils")

        -- Temporary fix for https://github.com/nvim-treesitter/nvim-treesitter/issues/3232
        require("nvim-treesitter.install").prefer_git = true

        local ts_utils = require("nvim-treesitter.ts_utils")
        local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

        require("nvim-treesitter.configs").setup({
            ensure_installed = {
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
            },
            query_linter = {
                enable = true,
                use_virtual_text = true,
                lint_events = { "BufWrite" },
            },
            sync_install = false,
            auto_install = true,
            ignore_install = {},
            highlight = {
                enable = true,
                disable = {},
                additional_vim_regex_highlighting = false,
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<cr>",
                    node_incremental = "<cr>",
                    scope_incremental = "<s-cr>",
                    node_decremental = "<bs>",
                },
            },
            textobjects = {
                select = {
                    enable = true,
                    lookahead = true,
                    keymaps = {
                        ["af"] = "@function.outer",
                        ["if"] = "@function.inner",
                        ["aa"] = "@parameter.outer",
                        ["ia"] = "@parameter.inner",
                        ["an"] = "@number.inner",
                        ["in"] = "@number.inner",
                        ["ag"] = "@comment.outer",
                        ["ig"] = "@comment.outer",
                        ["ac"] = "@conditional.outer",
                        ["ic"] = "@conditional.inner",
                        ["al"] = "@loop.outer",
                        ["il"] = "@loop.inner",
                    },
                    selection_modes = {
                        ["@function.inner"] = "V",
                        ["@function.outer"] = "V",
                    },
                },
                swap = {
                    enable = true,
                    swap_next = {
                        ["<localleader>al"] = "@parameter.inner",
                    },
                    swap_previous = {
                        ["<localleader>ah"] = "@parameter.inner",
                    },
                },
                move = {
                    enable = true,
                    set_jumps = true,
                    goto_next_start = {
                        ["<localleader>fn"] = "@function.outer",
                        ["<localleader>an"] = "@parameter.inner",
                    },
                    goto_previous_start = {
                        ["<localleader>fp"] = "@function.outer",
                        ["<localleader>ap"] = "@parameter.inner",
                    },
                },
            },
            endwise = {
                enable = true,
            },
        })

        local function run_and_center(func)
            return function()
                func()
                vim.cmd.normal("zz")
            end
        end

        map.set({ "n", "x", "o" }, "-", run_and_center(ts_repeat_move.repeat_last_move_next))
        map.set({ "n", "x", "o" }, "_", run_and_center(ts_repeat_move.repeat_last_move_previous))

        map.n.leader("ff", function()
            local node = ts.get_enclosing_top_level_function(ts_utils.get_node_at_cursor())

            if node ~= nil then
                -- Assume that the "name" child node is the function identifier/name
                local nodes = node:field("name")
                local function_name = #nodes > 0 and nodes[1] or node

                ts_utils.goto_node(function_name, false, false)
            end
        end, "Navigate to the enclosing top-level function")

        map.n.leader("fe", function()
            local node = ts.get_enclosing_top_level_function(ts_utils.get_node_at_cursor())

            if node ~= nil then
                local result = ts.get_end_of_enclosing_top_level_function(node)

                if result then
                    vim.fn.cursor(result.lnum, result.col)
                else
                    vim.notify("Could not find end of enclosing top-level function", vim.log.levels.ERROR)
                end
            end
        end, "Navigate to the end of the enclosing top-level function")

        -- Unmap incremental selection inside the command-line window
        vim.api.nvim_create_autocmd("CmdwinEnter", { command = "silent! nunmap <buffer> <cr>" })
    end,
}
