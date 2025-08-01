local map = {}

---@alias Mode "n" | "v" | "x" | "s" | "o" | "i" | "l" | "c" | "t"

---@type Mode[]
local modes = { "n", "i", "c", "v", "x", "s", "o", "t", "l" }

---@type table
map.default_options = { noremap = true, silent = true }

---@param opts1 table
---@param opts2 table?
function map.merge(opts1, opts2)
    return vim.tbl_extend("force", opts1, opts2 or {})
end

---@param options (table | string)?
function map.with_default_options(options)
    if type(options) == "string" then
        return map.merge(map.default_options, { desc = options })
    end

    return map.merge(map.default_options, options)
end

---@param mode Mode | Mode[]
---@param lhs string
---@param rhs string | function
---@param options (table | string)?
function map.set(mode, lhs, rhs, options)
    vim.keymap.set(mode, lhs, rhs, map.with_default_options(options))
end

---@param mode Mode | Mode[]
---@param lhs string | string[]
---@param options table?
function map.delete(mode, lhs, options)
    local lhs_to_delete = type(lhs) == "string" and { lhs } or lhs
    ---@cast lhs_to_delete string[]

    for _, _lhs in ipairs(lhs_to_delete) do
        vim.keymap.del(mode, _lhs, options)
    end
end

---@param mode Mode | Mode[]
---@param lhs string
---@param rhs string | fun()
---@param options (table | string)?
function map.leader(mode, lhs, rhs, options)
    local leader_lhs = '<localleader>' .. lhs

    map.set(mode, leader_lhs, rhs, options)
end

for _, mode in ipairs(modes) do
    map[mode] = setmetatable({}, {
        __call = function(_, lhs, rhs, options)
            map.set(mode, lhs, rhs, options)
        end,
        __index = function(_, key)
            if key == "leader" then
                return function(lhs, rhs, options)
                    map.leader(mode, lhs, rhs, options)
                end
            end

            error(("Invalid map index key: '%s'"):format(key))
        end
    })
end

return map
