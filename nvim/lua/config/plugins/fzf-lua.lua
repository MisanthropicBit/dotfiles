return {
    "ibhagwan/fzf-lua",
    branch = "main",
    config = function()
        local ansi = require("config.ansi")
        local colorschemes = require("config.colorschemes")
        local icons = require("config.icons")
        local map = require("config.map")
        local lsp_utils = require("config.lsp.utils")

        local fzf_lua = require("fzf-lua")
        local actions = require("fzf-lua.actions")

        -- Fzf-lua appears to use a weird space in results (0x2002 aka 'EN SPACE')
        local en_space = " "

        -- Returns a function for selecting a specific directory and then search it afterwards
        ---@param directory string
        ---@param options table?
        ---@return fun()
        local function project_files(directory, options)
            local file_selector = function(selector)
                return function(selected)
                    selector({ cwd = selected[1] })
                end
            end

            local _options = options or {}
            local command = ("fd --type directory --maxdepth %d . "):format(_options.maxdepth or 1)

            return function()
                fzf_lua.fzf_exec(command .. directory, {
                    cwd = directory,
                    prompt = "Search project " .. icons.misc.prompt .. " ",
                    actions = {
                        ["ctrl-s"] = file_selector(fzf_lua.files),
                        ["ctrl-o"] = file_selector(fzf_lua.lsp_workspace_symbols),
                        ["enter"] = file_selector(fzf_lua.files),
                        ["ctrl-g"] = file_selector(fzf_lua.git_files),
                        ["ctrl-r"] = file_selector(fzf_lua.grep_project),
                        ["ctrl-d"] = function(selected)
                            vim.cmd.tcd(selected[1])
                        end,
                    },
                    fzf_opts = {
                        ["--preview"] = "tree -C -L 1 {}",
                    },
                })
            end
        end

        --- Custom symbol formatter for fzf-lua's lsp
        ---@param symbol string
        ---@return string
        local function symbol_fmt(symbol)
            -- Fzf-lua passes the symbol wrapped in ansi escape codes if the option is
            -- set so we need to strip them before looking up the lsp kind icon
            local stripped = ansi.strip_ansi_codes(symbol)
            local icon = lsp_utils.kind_icons[stripped]

            if icon ~= nil then
                local color = lsp_utils.lsp_kind_to_rgb_ansi(stripped)

                if color == nil then
                    -- No highlight, extract ansi sequence provided by fzf-lua
                    -- NOTE: This might cause some color mismatches across the same lsp kinds
                    color = symbol:match(ansi.pattern())
                end

                -- Format as '  [Constant]'
                return string.format("%s%s [%s]%s", color, lsp_utils.kind_icons[stripped], stripped, ansi.reset_sequence())
            else
                return symbol
            end
        end

        fzf_lua.setup({
            winopts = {
                height = 0.75,
                preview = {
                    title_pos = "left",
                },
            },
            previewers = {
                builtin = {
                    title_fnamemodify = function(value)
                        local dirprefix = vim.fn.fnamemodify(value, ":h:t")
                        local filename = vim.fn.fnamemodify(value, ":t")

                        return table.concat({ dirprefix, filename }, "/")
                    end,
                },
            },
            hls = {
                preview_title = "Title",
            },
            keymap = {
                builtin = {
                    ["<c-+>"] = "toggle-help",
                    ["<c-p>"] = "preview-page-up",
                    ["<c-n>"] = "preview-page-down",
                },
                fzf = {
                    ["ctrl-h"] = "previous-history",
                    ["ctrl-l"] = "next-history",
                    ["ctrl-q"] = "select-all+accept",
                },
            },
            files = {
                find_opts = require("fzf-lua.defaults").defaults.files.find_opts .. " --exclude node_modules",
                formatter = "path.filename_first",
            },
            lsp = {
                git_icons = true,
                symbols = {
                    symbol_fmt = symbol_fmt,
                },
            },
            git = {
                files = {
                    formatter = "path.filename_first",
                },
                status = {
                    actions = {
                        ["ctrl-h"] = { actions.git_unstage, actions.resume },
                        ["ctrl-l"] = { actions.git_stage, actions.resume },
                        ["right"] = false,
                        ["left"] = false,
                        ["ctrl-x"] = false,
                    },
                },
                branches = {
                    cmd = "git branch --color --sort=-committerdate",
                },
                stash = {
                    actions = {
                        ["ctrl-o"] = { fn = actions.git_stash_pop, reload = true },
                    },
                },
                commits = {
                    actions = {
                        ["ctrl-s"] = function(selected)
                            vim.cmd("Gsplit " .. selected[1])
                        end,
                        ["ctrl-v"] = function(selected)
                            vim.cmd("Gvsplit " .. selected[1])
                        end,
                        ["ctrl-t"] = function(selected)
                            vim.cmd("Gtabedit " .. selected[1])
                        end,
                    },
                },
            },
            fzf_opts = {
                ["--cycle"] = "",
                ["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-history",
            },
            oldfiles = {
                -- Make oldfiles behave like fzf-vim's :History command
                include_current_session = true,
            },
            code_actions = {
                previewer = "codeaction_native",
            },
        })

        local function custom_colorschemes()
            local colors = colorschemes.get_preferred_colorschemes()

            fzf_lua.colorschemes({ colors = colors })
        end

        local function directories()
            fzf_lua.files({
                cmd = "fd --type directory",
                prompt = "Search directories" .. icons.misc.prompt .. " ",
                preview = "tree -L1 -C",
            })
        end

        local function open_file_under_cursor()
            fzf_lua.fzf_exec({ "horizontal split", "vertical split", "tab", "edit" }, {
                prompt = "Open in " .. icons.misc.prompt .. " ",
                winopts = {
                    width = 0.12,
                    height = 0.10,
                },
                actions = {
                    ["default"] = function(selected)
                        local cfile = vim.fn.expand("<cfile>")

                        if #cfile == 0 then
                            vim.notify("Found no filename under cursor", vim.log.levels.WARN, {})
                            return
                        end

                        local action = actions.file_split

                        if selected[1] == "vertical split" then
                            action = actions.file_vsplit
                        elseif selected[1] == "tab" then
                            action = actions.file_tabedit
                        elseif selected[1] == "edit" then
                            action = actions.file_edit
                        end

                        action({ cfile }, {})
                    end,
                }
            })
        end

        ---@return fun()
        local function open_file_in_branch()
            -- TODO: Does fzf-lua have a utility function for this?
            local function create_git_split_command(cmd, branch, path)
                local parts = vim.split(path, en_space)
                local trimmed = vim.trim(parts[#parts])
                return ("%s %s:%s"):format(cmd, branch, trimmed)
            end

            local git_file_selector = function(selected)
                local branch = vim.trim(selected[1])

                fzf_lua.git_files({
                    cmd = "git ls-tree -r --name-only " .. branch,
                    actions = {
                        ["ctrl-s"] = function(_selected)
                            vim.cmd(create_git_split_command("Gsplit", branch, _selected[1]))
                        end,
                        ["ctrl-v"] = function(_selected)
                            vim.cmd(create_git_split_command("Gvsplit", branch, _selected[1]))
                        end,
                        ["ctrl-t"] = function(_selected)
                            vim.cmd(create_git_split_command("Gtabedit", branch, _selected[1]))
                        end,
                    },
                })
            end

            local provider = fzf_lua.git_branches

            provider({
                cmd = "git branch --all --color --sort=-committerdate",
                prompt = "Select branch " .. icons.misc.prompt .. " ",
                actions = {
                    ["enter"] = git_file_selector,
                },
            })
        end

        -- TODO: Do 'norm zt' after jumping
        map.n("<c-s>", fzf_lua.lsp_document_symbols, "LSP document symbols")
        map.n("<c-w><c-s>", fzf_lua.lsp_workspace_symbols, "LSP workspace symbols")
        map.n("gb", fzf_lua.git_branches, "Git branches")
        map.n("<c-p>", fzf_lua.files, "Search files in current directory")
        map.n("<c-b><c-b>", fzf_lua.tabs, "List all buffers in all tabs")
        map.n.leader("lr", fzf_lua.lsp_references, "Show lsp references")
        map.n.leader("cc", custom_colorschemes, "Pick a colorscheme")
        map.n.leader("df", function()
            fzf_lua.files({ cwd = "~/projects/dotfiles/nvim" })
        end, "Search dotfiles")
        map.n.leader("gf", fzf_lua.git_files, "Search files in the current directory that are tracked by git")
        map.n.leader("gs", fzf_lua.git_status, "Git status")
        map.n.leader("gh", fzf_lua.git_stash, "Git stash")
        map.n.leader("bp", fzf_lua.dap_breakpoints, "List dap breakpoints")
        map.n.leader("hl", fzf_lua.highlights)
        map.n.leader("fb", fzf_lua.blines, "Find lines in current buffer")
        map.n.leader("hi", fzf_lua.oldfiles, "Search recent files")
        map.n.leader("hI", "<cmd>FzfLua oldfiles cwd_only=true<cr>", "Search recent files in current cwd only")
        map.n.leader("rg", fzf_lua.grep_project, "Search all project files")
        map.n.leader("pp", project_files(vim.fn.stdpath("data") .. "/lazy/"), "Search plugin directories")
        map.n.leader("rr", fzf_lua.resume, "Resume last search")
        map.n.leader("fd", directories, "Search directories")
        map.leader({ "n", "v" }, "la", function()
            fzf_lua.lsp_code_actions({ winopts = { height = 0.2, width = 0.33, preview = { layout = "vertical" } } })
        end)
        map.n("gf", open_file_under_cursor)
        map.n("go", open_file_in_branch)

        map.n.leader("ft", function() require("todo-comments.fzf").todo() end, {
            desc = "Find all TODOs",
            condition = "todo-comments",
        })

        map.n.leader("rt", function()
            fzf_lua.grep({ rg_opts = "-Tta " .. fzf_lua.defaults.grep.rg_opts })
        end, "Search all non-test files")

        local project_dir = vim.fn.isdirectory(vim.fs.normalize("~/repos")) == 1 and "~/repos" or "~/projects"
        local depth = project_dir == "~/projects" and 2 or 1

        map.leader("n", "pf", project_files(project_dir, { maxdepth = depth }), "Search all local repository files")

        fzf_lua.register_ui_select(function(_, items)
            local min_height, max_height = 0.15, 0.70
            local height = (#items + 4) / vim.o.lines
            height = math.min(math.max(height, min_height), max_height)

            return { winopts = { height = height, width = 0.33, row = 0.40 } }
        end)
    end,
}
