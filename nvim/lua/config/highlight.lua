local highlight = {}

function highlight.has_hl(name)
    -- NOTE: Ignores namespaces
    return vim.fn.hlexists(name) == 1
end

---@param ns_id integer
---@param opts table
---@return vim.api.keyset.hl_info
function highlight.get_hl(ns_id, opts)
    if opts.create ~= nil and not vim.fn.has("nvim-0.10.0") == 1 then
        opts.create = nil
    end

    return vim.api.nvim_get_hl(ns_id, vim.tbl_extend("force", opts, { link = false }))
end

function highlight.set_hl(ns_id, name, options)
    vim.api.nvim_set_hl(ns_id, name, options)
end

local function resolve_color_spec(ns_id, key, options)
    if options[key] then
        if options[key][1]:match("^#[a-fA-F0-9]+$") then
            return { fg = options[key][1] }
        else
            local group = highlight.get_hl(ns_id, { name = options[key][1] })

            if group[options[key][2]] then
                return { [key] = group[options[key][2]] }
            -- else
            --     return { [key] = group[options[key == "fg" and "bg" or "fg"][2]] }
            end
        end
    end

    return { [key] = options[key][2] }
end

---@param ns_id integer
---@param name string
---@param options table
function highlight.create_hl_from(ns_id, name, options)
    local exists = highlight.get_hl(ns_id, { name = name })

    if table.maxn(exists) ~= 0 then
        return exists
    end

    local colors = { force = true, default = false }

    colors = vim.tbl_extend("force", colors, resolve_color_spec(ns_id, "fg", options))
    colors = vim.tbl_extend("force", colors, resolve_color_spec(ns_id, "bg", options))

    highlight.set_hl(ns_id, name, colors)
end

return highlight
