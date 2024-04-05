local fzf_lua_setup = {}

local ansi = require("config.ansi")
local colorschemes = require("config.colorschemes")
local icons = require("config.icons")
local map = require("config.map")
local lsp_utils = require("config.lsp.utils")

local fzf_lua = require("fzf-lua")
local actions = require("fzf-lua.actions")

-- Returns a function for selecting a specific directory and then search it afterwards
---@param directory string
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
        },
    },
    lsp = {
        git_icons = true,
        symbols = {
            symbol_fmt = symbol_fmt,
        },
    },
    git = {
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

-- TODO: Do 'norm zt' after jumping
map.n("<c-s>", fzf_lua.lsp_document_symbols, "LSP document symbols")
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
map.n.leader("pp", project_files("~/.vim-plug/"), "Search plugin directories")
map.n.leader("rr", fzf_lua.resume, "Resume last search")
map.n.leader("fd", directories, "Search directories")
map.leader({ "n", "v" }, "la", function() fzf_lua.lsp_code_actions({ winopts = { height = 0.2, width = 0.33, preview = { layout = "vertical" } } }) end)

map.n("gf", function()
    fzf_lua.fzf_exec({ "horizontal split", "vertical split", "tab" }, {
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
                end

                action({ cfile }, {})
            end,
        }
    })
end)

local project_dir = vim.fn.isdirectory(vim.fs.normalize("~/repos")) and "~/repos" or "~/projects"
local depth = project_dir == "~/projects" and 2 or 1

map.leader("n", "pf", project_files(project_dir, { maxdepth = depth }), "Search all local repository files")

fzf_lua.register_ui_select(function(_, items)
    local min_height, max_height = 0.15, 0.70
    local height = (#items + 4) / vim.o.lines
    height = math.min(math.max(height, min_height), max_height)

    return { winopts = { height = height, width = 0.33, row = 0.40 } }
end)

return fzf_lua_setup
