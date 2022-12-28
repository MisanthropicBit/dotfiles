local M = {}

M.default_options = { noremap = true, silent = true }

function M.set(mode, lhs, rhs, opts)
    local options = vim.tbl_extend('force', M.default_options, opts)

    vim.keymap.set(mode, lhs, rhs, options)
end

function M.merge(opts1, opts2)
    return vim.tbl_extend('force', opts1, opts2)
end

function M.with_default_options(opts)
    return M.merge(M.default_options, opts)
end

return M
