-- Configuration assumes neovim 0.9.0+

local icons = require("config.icons")

if vim.fn.has("nvim-0.9.0") == 1 then
    vim.loader.enable()
end

local g = vim.g
local o = vim.o
local opt = vim.opt

g.mapleader = " "
g.maplocalleader = vim.g.mapleader
g.is_bash = true
g.sql_type_default = "mysql"
g.python_host_prog = vim.fn.expand("~/.neovim_venvs/neovim2/bin/python")
g.python3_host_prog = vim.fn.expand("~/.neovim_venvs/neovim3/bin/python")
g.custom_notifier = "terminal-notifier"
g.use_custom_notifier = true
g.notify_log_level = vim.log.levels.WARN

o.compatible = false
o.number = true
o.relativenumber = true
o.laststatus = 2
o.wildmenu = true
o.cursorline = true
o.scrolloff = 3
o.ruler = true
o.visualbell = true
o.showbreak = icons.text.linebreak
o.shiftround = true
o.linebreak = true
o.formatoptions = "croqlnt"
o.ignorecase = true
o.smartcase = true
o.signcolumn = "yes:2"
o.updatetime = 500
o.swapfile = false
o.hlsearch = true
o.incsearch = true
o.expandtab = true
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.autoindent = true
o.tabpagemax = 15
o.showtabline = 2
o.splitright = true
o.foldlevel = 3 -- Only close folds that are at level 3 or higher
o.foldmethod = "indent"
o.foldnestmax = 3
o.shell = "fish"
o.inccommand = "nosplit"
vim.cmd([[set keywordprg=:DocsCursor]])

opt.backspace = { "indent", "eol", "start" }
opt.clipboard:append("unnamed")

-- stylua: ignore start
opt.wildignore:append({
    ".hg",".git",".svn",                                         -- Version control files
    "*.aux","*.bbl","*.bcf","*.blg","*.run.xml","*.toc","*.xdv", -- LaTeX files
    "*.acn","*.glo","*.ist","*.pag","*.synctex.gz",              -- More LaTeX files
    "*.jpeg","*.jpg","*.bmp","*.gif","*.png","*.tiff",           -- Image files
    "*.o","*.obj","*.exe","*.dll","*.*.manifest",                -- Object files
    "*.sw?",                                                     -- vim swap files
    "*.pyc",                                                     -- Python bytecode files
    "*.class",                                                   -- Java class files
    "*.fdb_latexmk","*.fls",                                     -- Latexmk build files
})
-- stylua: ignore end

opt.suffixes:append("*.log")

-- Add fzf paths for both homebrew and macports
opt.rtp:append({ "/opt/local/share/fzf/vim", "/usr/local/opt/fzf" })

-- Get rid of default preprocessor directive indentation rules which removes all indentation
opt.cinkeys:remove("0#")
opt.indentkeys:remove("0#")

if vim.fn.has("gui_running") == 0 then
    if vim.fn.has("termguicolors") then
        o.termguicolors = true
    else
        -- TODO:
    end
end

if vim.fn.executable("rg") then
    o.grepprg = "rg --vimgrep --smart-case"
    o.grepformat = [[%f:%l:%c:%m]]
else
    o.grepprg = "grep --line-number --recursive"
end

-- Highlight git merge conflict markers
vim.cmd([[match ErrorMsg '\v^(\<|\=|\>){7}([^\=].+)?$']])

require("config.keymaps")
require("config.autocmds")
require("config.commands")
require("config.filetypes")
require("config.notify")
require("config.plugins.setup")
require("config.colorschemes").select_random_color_scheme()
require("config.plugins")
require("config.diagnostic")
require("config.diagnostics_levels")
require("config.lsp")
require("config.docs")
require("config.fold")
