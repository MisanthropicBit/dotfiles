local icons = require("config.icons")

local g = vim.g
local o = vim.o
local opt = vim.opt

g.mapleader = " "
g.maplocalleader = vim.g.mapleader
g.is_bash = true
g.sql_type_default = "mysql"
g.python_host_prog = vim.fn.expand("~/.neovim_venvs/neovim2/bin/python")
g.python3_host_prog = vim.fn.expand("~/.neovim_venvs/neovim3/bin/python")
g.custom_notifier = nil
g.notify_log_level = vim.log.levels.WARN
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
g.loaded_netrwSettings = 1
g.loaded_netrwFileHandlers = 1

o.compatible = false
o.number = true
o.relativenumber = true
o.laststatus = 3
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
o.inccommand = "nosplit"
o.undofile = true

if type(vim.env.SHELL) == "string" and vim.env.SHELL:match("fish") then
    o.shell = "fish"
end

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

if vim.fn.executable("rg") == 1 then
    o.grepprg = "rg --vimgrep --smart-case"
    o.grepformat = [[%f:%l:%c:%m]]
else
    o.grepprg = "grep --line-number --recursive"
end
