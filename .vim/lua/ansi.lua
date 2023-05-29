local ansi = {}

local bit = require('bit')

-- Extract the RGB components from a color number
function ansi.extract_rgb(color)
    local r = bit.band(bit.rshift(color, 16), 0xff)
    local g = bit.band(bit.rshift(color, 8), 0xff)
    local b = bit.band(bit.rshift(color, 0), 0xff)

    return r, g, b
end

-- Convert a color number to an ANSI escape code
function ansi.rgb_to_ansi(encoded_color, is_bg)
    if encoded_color == nil then
        return ''
    end

    local r, g, b = ansi.extract_rgb(encoded_color)
    local ansi_code = is_bg and '48' or '38'

    return string.format('\x1b[%s;2;%s;%s;%sm', ansi_code, r, g, b)
end

-- Convert a vim highlight group to an RGB ANSI escape code
---@param hl_name string
function ansi.highlight_to_rgb_ansi(hl_name)
    local colors = vim.api.nvim_get_hl(0, { name = hl_name, link = false })
    local _ansi = ansi.rgb_to_ansi(colors.fg, false)
    _ansi = _ansi .. ansi.rgb_to_ansi(colors.bg, true)

    return _ansi
end

--- Return a pattern for matching ansi escape sequences
---@return string
function ansi.pattern()
    return '\x1b%[[0-9;K]+m'
end

--- Return the ansi escape sequence for resetting escape sequences
---@return string
function ansi.reset_sequence()
    return '\x1b[0m'
end

--- Strip ansi escape sequences from a string
---@param value string
---@return string
function ansi.strip_ansi_codes(value)
    local stripped, _ = value:gsub(ansi.pattern(), '')

    return stripped
end

return ansi
