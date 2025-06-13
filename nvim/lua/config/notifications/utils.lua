local utils = {}

---@param msg string
---@return string
function utils.escape_message(msg)
    local escaped = (msg:sub(1, 1) == "[" and "\\" .. msg or msg):gsub('"', '\\"')

    return escaped
end


return utils
