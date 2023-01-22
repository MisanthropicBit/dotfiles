local M = {}

M.default_options = { noremap = true, silent = true }

function M.merge(opts1, opts2)
    return vim.tbl_extend('force', opts1, opts2)
end

function M.with_default_options(opts)
    return M.merge(M.default_options, opts)
end

function M.set(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, M.with_default_options(opts))
end

function M.leader(mode, lhs, rhs, opts)
    local leader_lhs = '<localleader>' .. lhs

    vim.keymap.set(mode, leader_lhs, rhs, M.with_default_options(opts))
end

return M
