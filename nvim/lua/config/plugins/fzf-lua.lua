local fzf_lua_setup = {}

local ansi = require("config.ansi")
local colorschemes = require("config.colorschemes")
local map = require("config.map")
local lsp_utils = require("config.lsp.utils")

local fzf_lua = require("fzf-lua")
local actions = require("fzf-lua.actions")

-- Returns a function for selecting a specific directory and then search it afterwards
---@param directory string
---@return fun()
local function project_files(directory)
    local file_selector = function(selector)
        return  function(selected)
            selector({ cwd = selected[1] })
        end

    end

    return function()
        fzf_lua.fzf_exec("fd --type directory --maxdepth 1 . " .. directory, {
            cwd = directory,
            prompt = "Search directory❯ ",
            actions = {
                ["ctrl-s"] = file_selector(fzf_lua.files),
                ["enter"] = file_selector(fzf_lua.files),
                ["ctrl-g"] = file_selector(fzf_lua.git_files),
                ["ctrl-r"] = file_selector(fzf_lua.grep_project),
            },
            fzf_opts = {
                ["--preview"] = vim.fn.shellescape("tree -C -L 1 {}"),
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
                ["ctrl-h"] = { actions.git_stage, actions.resume },
                ["ctrl-l"] = { actions.git_unstage, actions.resume },
                ["right"] = false,
                ["left"] = false,
                ["ctrl-x"] = false,
            },
        },
    },
    fzf_opts = {
        ["--cycle"] = "",
    },
    oldfiles = {
        -- Make oldfiles behave like fzf-vim's :History command
        include_current_session = true,
    },
    code_actions = {
        previewer = "codeaction_native",
    }
})

local function custom_colorschemes()
    local colors = colorschemes.get_preferred_colorschemes()

    fzf_lua.colorschemes({ colors = colors })
end

local function directories()
    fzf_lua.fzf_exec("fd --type directory", {
        prompt = "Search directories> ",
        actions = {
            ["default"] = function(selected)
                vim.cmd.edit(selected[1])
            end,
            ["ctrl-s"] = function(selected)
                vim.cmd.split(selected[1])
            end,
            ["ctrl-v"] = function(selected)
                vim.cmd.vsplit(selected[1])
            end,
            ["ctrl-t"] = function(selected)
                vim.cmd.tabedit(selected[1])
            end,
            ["ctrl-d"] = function(selected)
                vim.cmd.tcd(selected[1])
            end,
        },
    })
end

-- TODO: Do 'norm zt' after jumping
map.n("<c-s>", fzf_lua.lsp_document_symbols, "LSP document symbols")
map.leader("n", "lr", fzf_lua.lsp_references, "Show lsp references")

map.n("<c-p>", fzf_lua.files, "Search files in current directory")
map.leader("n", "cc", custom_colorschemes, "Pick a colorscheme")
map.leader("n", "df", function()
    fzf_lua.files({ cwd = "~/projects/dotfiles/nvim" })
end, "Search dotfiles")
map.leader("n", "gf", fzf_lua.git_files, "Search files in the current directory that are tracked by git")
map.leader("n", "gs", fzf_lua.git_status, "Git status")
map.leader("n", "gh", fzf_lua.git_stash, "Git stash")
map.leader("n", "gr", fzf_lua.git_branches, "Git branches")
map.leader("n", "bp", fzf_lua.dap_breakpoints, "List dap breakpoints")
map.leader("n", "hl", fzf_lua.highlights)
map.leader("n", "fb", fzf_lua.blines, "Find lines in current buffer")
map.leader("n", "hi", fzf_lua.oldfiles, "Search recent files")
map.leader("n", "rg", fzf_lua.grep_project, "Search all project files")
map.leader("n", "pf", project_files("~/repos"), "Search all local repository files")
map.leader("n", "pp", project_files("~/.vim-plug/"), "Search plugin directories")
map.leader("n", "rr", fzf_lua.resume, "Resume last search")
map.leader("n", "fd", directories, "Search directories")
map.n("<c-b><c-b>", fzf_lua.tabs, "List all buffers in all tabs")

vim.cmd("FzfLua register_ui_select")

return fzf_lua_setup
