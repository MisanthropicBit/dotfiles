local M = {}

local bit = require('bit')

-- Extract the RGB components from a color number
function M.extract_rgb(color)
    local r = bit.band(bit.rshift(color, 16), 0xff)
    local g = bit.band(bit.rshift(color, 8), 0xff)
    local b = bit.band(bit.rshift(color, 0), 0xff)

    return r, g, b
end

-- Convert a color number to an ANSI escape code
function M.rgb_to_ansi(encoded_color, is_bg)
    if encoded_color == nil then
        return ''
    end

    local r, g, b = M.extract_rgb(encoded_color)
    local ansi_code = is_bg and '48' or '38' 

    return string.format('\x1b[%s;2;%s;%s;%sm', ansi_code, r, g, b)
end

-- Convert a vim highlight group to an RGB ANSI escape code
---@type string hl_name
function M.highlight_to_rgb_ansi(hl_name)
    local colors = vim.api.nvim_get_hl_by_name(hl_name, true)
    -- local colors = { foreground = 16394340 }
    local ansi = M.rgb_to_ansi(colors.foreground, false)
    ansi = ansi .. M.rgb_to_ansi(colors.background, true)

    return ansi
end

return M
