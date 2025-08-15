local ts = {}

local function_nodes = {
    "arrow_function",
    "function",
    "function_definition",
    "function_declaration",
    "method_definition",
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

        ---@diagnostic disable-next-line: cast-local-type
        node = node:parent()
    end

    return result
end

---@param node TSNode
---@return { lnum: integer, col: integer }?
function ts.get_end_of_enclosing_top_level_function(node)
    local func_node = ts.get_enclosing_top_level_function(node)

    if func_node then
        local lnum, col, _ = func_node:end_()

        return { lnum = lnum + 1, col = col + 1 }
    end

    return nil
end

---@param node TSNode
---@return TSNode?
function ts.get_next_top_level_function(node)
    local result_node = nil
    local func_node = ts.get_enclosing_top_level_function(node)

    if func_node then
        result_node = func_node:next_sibling()
    else
        result_node = node:next_sibling()
    end

    while result_node and not is_function_node(result_node) do
        result_node = result_node:next_sibling()
    end

    return result_node
end

---@param node TSNode
---@return TSNode?
function ts.get_prev_top_level_function(node)
    local result_node = nil
    local func_node = ts.get_enclosing_top_level_function(node)

    if func_node then
        result_node = func_node:prev_sibling()
    else
        result_node = node:prev_sibling()
    end

    while result_node and not is_function_node(result_node) do
        result_node = result_node:prev_sibling()
    end

    return result_node
end

---@param node TSNode
---@return TSNode?
function ts.get_enclosing_function_node(node)
    while node ~= nil do
        if is_function_node(node) then
            return node
        end

        ---@diagnostic disable-next-line: cast-local-type
        node = node:parent()
    end

    return node
end

return ts
