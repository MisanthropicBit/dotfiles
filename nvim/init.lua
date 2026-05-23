local min_nvim_version = "nvim-0.11.0"

if vim.fn.has(min_nvim_version) == 0 then
    vim.notify(("Configuration requires at least %s, current version is nvim-%s"):format(
        min_nvim_version,
        vim.version()
    ), vim.log.levels.ERROR)

    return
end

if vim.fn.has("nvim-0.12.0") == 1 then
    require("vim._core.ui2").enable({
    	enable = true,
        targets = "msg",
        msg = {
            targets = {
                [""] = "msg",
                list_cmd = "pager",
                progress = "msg",
                confirm = "dialog",
            }
        }
    })

    vim.cmd.packadd("nvim.difftool")
    vim.cmd.packadd("nvim.undotree")
end

vim.loader.enable()

if vim.fn.has("nvim-0.12") == 1 then
    vim.pack.add({
        {
            src = "https://github.com/ConradIrwin/vim-bracketed-paste",
            -- version = "77e5220b8ac541f9244e57a252655b748e21c71e",
        },
        "https://github.com/windwp/nvim-autopairs",
        "https://github.com/rgroli/other.nvim",
    })

    vim.opt.rtp:prepend("/Users/hyrule/projects/nvim/parcel.nvim")
    -- require("parcel").setup()
end

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.commands")
require("config.run")
require("config.filetypes")
require("config.notifications").setup()
require("config.plugins")
require("config.diagnostic")
require("config.diagnostics_levels")
require("config.lsp")
require("config.fold")

require("config.colorschemes").select_random_color_scheme()

local ui = require("config.ui")

ui.tabline.register()
ui.input.register_default()

vim.cmd.packadd("cfilter")
-- vim.cmd.packadd("nvim.undotree")

-- Highlight git merge conflict markers
vim.cmd([[match ErrorMsg '\v^(\<|\=|\>){7}([^\=].+)?$']])
