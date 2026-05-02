return {
    src = "https://www.github.com/ibhagwan/fzf-lua",
    version = "main",
    data = {
        config = function(fzf_lua)
            require("config.fzf-lua-setup")
            local actions = require("fzf-lua.actions")
            local colorschemes = require("config.colorschemes")
            local icons = require("config.icons")
            local map = require("config.map")

            -- Fzf-lua appears to use a weird space in results (0x2002 aka 'EN SPACE')
            local en_space = " "

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
                    },
                })
            end

            ---@diagnostic disable-next-line: unused-local, unused-function
            local function open_file_in_branch()
                -- TODO: Does fzf-lua have a utility function for this?
                local function create_git_split_command(cmd, branch, path)
                    local parts = vim.split(path, en_space)
                    local path_parts = vim.split(parts[#parts], "\t")
                    local trimmed = vim.trim(path_parts[2] .. "/" .. path_parts[1])

                    return ("%s %s:%s"):format(cmd, branch, trimmed)
                end

                ---@diagnostic disable-next-line: unused-local, unused-function
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

            -- TODO: Do 'norm zt' after jumping
            map.n("<c-s>", fzf_lua.lsp_document_symbols)
            map.n("<c-w><c-s>", fzf_lua.lsp_workspace_symbols)
            map.n("gb", fzf_lua.git_branches)
            map.n("<c-p>", fzf_lua.files)
            map.n("<c-b><c-b>", fzf_lua.buffers)
            map.n.leader("lr", fzf_lua.lsp_references)
            map.n.leader("cc", custom_colorschemes)
            map.n.leader("df", function()
                fzf_lua.files({ cwd = "~/projects/dotfiles" })
            end, "Search dotfiles")
            map.n.leader("gf", fzf_lua.git_files)
            map.n.leader("gg", fzf_lua.git_status)
            map.n.leader("gh", fzf_lua.git_stash)
            map.n.leader("bp", fzf_lua.dap_breakpoints)
            map.n.leader("hl", fzf_lua.highlights)
            map.n.leader("fb", fzf_lua.blines)
            map.n.leader("hi", fzf_lua.oldfiles)
            map.n.leader("hI", function()
                fzf_lua.oldfiles({ cwd_only = true })
            end, "Search recent files in current cwd only")
            map.n.leader("rg", fzf_lua.grep_project)
            map.n.leader("pp", project_files(vim.fn.stdpath("data") .. "/site/pack/core/opt"), "Search plugin directories")
            map.n.leader("rr", fzf_lua.resume, "Resume last search")
            map.n.leader("fd", directories)
            map.n.leader("bb", fzf_lua.tabs)
            map.n.leader("fw", fzf_lua.grep_cword)
            map.n.leader("fW", fzf_lua.grep_cWORD)
            map.n.leader("fg", fzf_lua.live_grep_native)
            map.n.leader("fG", fzf_lua.live_grep)
            map.n.leader("cm", fzf_lua.command_history)
            map.leader({ "n", "v" }, "la", function()
                fzf_lua.lsp_code_actions({
                    winopts = { height = 0.2, width = 0.33, preview = { layout = "vertical" } },
                })
            end)
            map.n("gf", open_file_under_cursor)
            -- map.n("go", open_file_in_branch)

            map.n.leader("ft", function()
                require("todo-comments.fzf").todo()
            end, "Find all TODOs")
            map.n.leader("rt", function()
                fzf_lua.grep_project({ rg_opts = "-Tta " .. fzf_lua.defaults.grep.rg_opts })
            end, "Search all non-test files")

            local project_dir = vim.fn.isdirectory(vim.fs.normalize("~/repos")) == 1 and "~/repos" or "~/projects"
            local depth = project_dir == "~/projects" and 2 or 1

            map.n.leader("pf", project_files(project_dir, { maxdepth = depth }), "Search all local repository files")

            map.set({ "v", "i" }, "<c-x><c-f>", function()
                fzf_lua.complete_path()
            end)

            fzf_lua.register_ui_select(function(_, items)
                local min_height, max_height = 0.15, 0.70
                local height = (#items + 4) / vim.o.lines
                height = math.min(math.max(height, min_height), max_height)

                return { winopts = { height = height, width = 0.33, row = 0.40 } }
            end)
        end,
    },
}
