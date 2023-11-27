local ts = {}

---@param node TSNode
---@return TSNode?
function ts.get_enclosing_top_level_function(node)
    local result = nil

    while node ~= nil do
        if node:type() == "function_declaration" then
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
        if node:type() == "function_declaration" then
            return node
        end

        node = node:parent()
    end

    return node
end

return ts
