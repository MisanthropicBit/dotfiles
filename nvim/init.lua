-- Configuration assumes neovim 0.9.0+

if vim.fn.has("nvim-0.9.0") == 1 then
    vim.loader.enable()
end

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
require("config.ui").input.register_default()
