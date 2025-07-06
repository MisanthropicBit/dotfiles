-- Configuration assumes neovim 0.9.0+
local min_nvim_version = "nvim-0.11.0"

if vim.fn.has(min_nvim_version) == 0 then
    vim.notify(("Configuration requires at least %s, current version is nvim-%s"):format(
        min_nvim_version,
        vim.version()
    ), vim.log.levels.ERROR)

    return
end

vim.loader.enable()

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.commands")
require("config.filetypes")
require("config.notifications")
require("config.plugin-setup")
require("config.diagnostic")
require("config.diagnostics_levels")
require("config.lsp")
require("config.fold")

require("config.colorschemes").select_random_color_scheme()
require("config.tabline").register()
require("config.ui").input.register_default()
