local default_exclude_filetypes = vim.list_slice(require("ibl.config").default_config.exclude.filetypes)

vim.list_extend(default_exclude_filetypes, { "dashboard", "fugitive" })

require("ibl").setup({
    enabled = true,
    indent = {
        char = "│",
    },
    scope = {
        enabled = true,
        show_start = true,
    },
    exclude = {
        filetypes = default_exclude_filetypes,
    },
})
