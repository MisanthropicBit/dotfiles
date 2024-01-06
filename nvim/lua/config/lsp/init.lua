local augroup = vim.api.nvim_create_augroup("ConfigLspAttach", {})

vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup,
	callback = function(event)
		require("config.lsp.on_attach").on_attach(event)
	end,
})

-- Globally override lsp border settings
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

---@diagnostic disable-next-line:duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "rounded"

    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

require("config.lsp.lsp_configs")
