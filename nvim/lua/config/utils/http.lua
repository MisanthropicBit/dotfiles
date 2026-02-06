local http = {}

-- stylua: ignore start
---@type number[]
local http_codes = {
    100, 101, 102, 103, 200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301, 302, 303, 304, 307,
    308, 400, 401, 402, 403, 404, 405, 406, 407, 408, 409, 410, 411, 412, 413, 414, 415, 416, 417, 418,
    421, 422, 423, 424, 425, 426, 428, 429, 431, 451, 500, 501, 502, 503, 504, 505, 506, 507, 508, 510, 511,
}
-- stylua: ignore end

---@param value string
---@return string?
function http.is_supported_code(value)
    local number = tonumber(value)

    if not number then
        return nil
    end

    return vim.list_contains(http_codes, number) and value or nil
end

---@param http_code string
function http.lookup_code(http_code)
    vim.ui.open("https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/" .. http_code)
end

return http
