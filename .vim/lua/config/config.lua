-- vim.g.custom_notifier = 'terminal-notifier'
-- vim.g.use_custom_notifier = true

-- require('notify')
-- local colorschemes = require('colorschemes')

-- local function is_valid_string_option(name)
--     return name and type(name) == 'string' and #name > 0
-- end

-- if is_valid_string_option(vim.g.default_colorscheme_override) then
--     vim.cmd('<cmd>colorscheme ' .. vim.g.default_colorscheme_override)
-- else
--     colorschemes.select_random_color_scheme()
-- end

-- require('plugins')
-- require('diagnostic')
-- require('lsp')
-- require('docs')
-- require('fold')
-- require('diagnostics_levels')

-- pcall(require, 'private_plugins')

-- local yank_group = vim.api.nvim_create_augroup('HighlightYank', {})

-- vim.api.nvim_create_autocmd('TextYankPost', {
--     group = yank_group,
--     pattern = '*',
--     callback = function()
--         vim.highlight.on_yank({
--             higroup = 'IncSearch',
--             timeout = 40,
--         })
--     end,
-- })
