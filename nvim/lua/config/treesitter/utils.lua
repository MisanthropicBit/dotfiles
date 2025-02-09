local ts = {}

local function_nodes = {
    "function",
    "function_declaration",
    "arrow_function",
}

---@param node TSNode
---@return boolean
local function is_function_node(node)
    return vim.tbl_contains(function_nodes, node:type())
end

---@param node TSNode
---@return TSNode?
function ts.get_enclosing_top_level_function(node)
    local result = nil

    while node ~= nil do
        if is_function_node(node) then
            result = node
        end

        node = node:parent()
    end

    return result
end

---@param node TSNode
---@return TSNode?
function ts.get_enclosing_function_node(node)
    while node ~= nil do
        if is_function_node(node) then
            return node
        end

        node = node:parent()
    end

    return node
end

return ts
