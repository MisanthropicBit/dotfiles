local map = {}

---@class config.MapSetOptions: vim.keymap.set.Opts
---@field check boolean? Check if the mapping exists and do not set it if it does

---@alias Mode "n" | "v" | "x" | "s" | "o" | "i" | "l" | "c" | "t"

---@type Mode[]
local modes = { "n", "i", "c", "v", "x", "s", "o", "t", "l" }

---@type config.MapSetOptions
map.default_options = { noremap = true, silent = true }

---@param opts1 config.MapSetOptions
---@param opts2 config.MapSetOptions?
---@return config.MapSetOptions
function map.merge(opts1, opts2)
    return vim.tbl_extend("force", opts1, opts2 or {})
end

---@param options (config.MapSetOptions | string)?
---@return config.MapSetOptions
function map.with_default_options(options)
    if type(options) == "string" then
        return map.merge(map.default_options, { desc = options })
    end

    return map.merge(map.default_options, options)
end

---@param mode Mode | Mode[]
---@param lhs string
---@param rhs string | function
---@param options (config.MapSetOptions | string)?
function map.set(mode, lhs, rhs, options)
    local _options = map.with_default_options(options)

    if _options.check ~= nil then
        local check = _options.check

        if check == true then
            local _modes = type(mode) == "string" and { mode } or mode
            ---@cast _modes Mode[]

            for _, _mode in ipairs(_modes) do
                if vim.fn.maparg(lhs, _mode) ~= "" then
                    return
                end
            end
        end

        -- vim.keymap.set will throw on unknown keys
        _options.check = nil
    end

    vim.keymap.set(mode, lhs, rhs, map.with_default_options(_options))
end

---@param mode Mode | Mode[]
---@param lhs string | string[]
---@param options vim.keymap.del.Opts?
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
---@param options (config.MapSetOptions | string)?
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
