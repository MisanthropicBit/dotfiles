local map = {}

---@alias Mode 'n' | 'v' | 'x' | 's' | 'o' | 'i' | 'l' | 'c' | 't'

---@type table
map.default_options = { noremap = true, silent = true }

---@param opts1 table
---@param opts2 table?
function map.merge(opts1, opts2)
    return vim.tbl_extend('force', opts1, opts2 or {})
end

---@param opts table?
function map.with_default_options(opts)
    return map.merge(map.default_options, opts)
end

---@param mode Mode
---@param lhs string
---@param rhs string | fun()
---@param opts table?
function map.set(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, map.with_default_options(opts))
end

---@param mode Mode
---@param lhs string
---@param rhs string | fun()
---@param opts table?
function map.leader(mode, lhs, rhs, opts)
    local leader_lhs = '<localleader>' .. lhs

    vim.keymap.set(mode, leader_lhs, rhs, map.with_default_options(opts))
end

for _, mode in ipairs({ 'n', 'i', 'c', 'v', 'x', 's', 'o', 't', 'l' }) do
    map[mode] = function(lhs, rhs, opts)
        map.set(mode, lhs, rhs, opts)
    end
end

return map
