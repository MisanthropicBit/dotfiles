local M = {}

local kind_icons = require('lsp_common').kind_icons
local bit = require('bit')

local kind_icons_keys = vim.tbl_keys(kind_icons)
local fzf_preview_window_option = vim.g.fzf_preview_window or 'right:+{2}-/2'

-- Extract the RGB components from a color number
local function extract_rgb(color)
    local r = bit.band(bit.rshift(color, 16), 0xff)
    local g = bit.band(bit.rshift(color, 8), 0xff)
    local b = bit.band(bit.rshift(color, 0), 0xff)

    return r, g, b
end

-- Convert a color number to an ANSI escape code
local function rgb_to_ansi(encoded_color, is_bg)
    if encoded_color == nil then
        return ''
    end

    local r, g, b = extract_rgb(encoded_color)
    local ansi_code = is_bg and '48' or '38' 

    return string.format('\x1b[%s;2;%s;%s;%sm', ansi_code, r, g, b)
end

-- Convert a vim highlight group to an RGB ANSI escape code
local function highlight_to_rgb_ansi(hl_name)
    -- local colors = vim.api.nvim_get_hl_by_name(hl_name, true)
    local colors = { foreground = 16394340 }
    local ansi = rgb_to_ansi(colors.foreground, false)
    ansi = ansi .. rgb_to_ansi(colors.background, true)

    return ansi
end

-- Map lsp kinds to vim highlight groups
local kind_to_hl = {
    Class = 'StorageClass',
    Constructor = 'Function',
    Color = 'Type',
    Enum = 'StorageClass',
    EnumMember = 'Identifier',
    Field = 'Label',
}

-- Construct a table from lsp kinds to a highlight group
local function construct_kind_to_cmp_hl_table(kinds)
    local kind_to_cmp_hl_table = {}

    for _, kind in pairs(kinds) do
        kind_to_cmp_hl_table[kind] = 'CmpItemKind' .. kind
    end

    return kind_to_cmp_hl_table
end

local kind_to_cmp_hl = construct_kind_to_cmp_hl_table(kind_icons_keys)

local function construct_rgb_ansi_table(kinds)
    local ansi_rgb_table = {}

    for _, kind in pairs(kinds) do
        ansi_rgb_table[kind] = highlight_to_rgb_ansi(kind_to_cmp_hl[kind])
    end

    return ansi_rgb_table
end

-- 256-color ansi escape codes
-- true-color ansi escape codes
local ansi = {
    {
        reset = '\x1b[0m',
        red = '\x1b[31m',
        green = '\x1b[32m',
        yellow = '\x1b[33m',
        blue = '\x1b[34m',
        purple = '\x1b[35m',
    },
    construct_rgb_ansi_table(kind_icons_keys),
}

local function construct_lsp_symbol_colors(kinds, ansi_codes)
    local color_table = {}
    local has_gui_colors = vim.o.termguicolors and 2 or 1

    for _, kind in pairs(kinds) do
        color_table[kind] = ansi_codes[has_gui_colors][string.lower(kind)]
    end

    return color_table
end

local kind_colors = construct_lsp_symbol_colors(kind_icons_keys, ansi)

local function lsp_to_fzf(item)
    local result = vim.split(item.text, '%]')
    local kind, item_name = string.sub(result[1], 2), string.sub(result[2], 2)
    local kind_icon = kind_icons[kind] or kind

    return string.format(
        '%s%s%s %s %s %d %d',
        '\x1b[35m',
        kind_icon,
        '\x1b[0m',
        item_name,
        item.filename,
        item.lnum,
        item.col
    )
end

local function fzf_to_lsp(entry)
    local location = vim.split(string.match(entry, '.+ %d+ %d+'), ' ')
    local uri = vim.uri_from_fname(vim.fn.fnamemodify(vim.fn['fzf#shellescape'](vim.fn.expand(location[1])), ':p'))
    local position = {
        line = tonumber(location[2]) - 1,
        character = tonumber(location[3]) - 1
    }

    return {
        uri = uri,
        range = { start = position, ['end'] = position },
    }
end

local function jump(entries)
    if not entries or #entries < 2 then
        return
    end

    -- Retrieve user action
    local key = table.remove(entries, 1)
    -- local action = 'vsp' -- opts.fzf_action[key]

    -- Apply user action to all entries if it's a function
    -- if type(action) == 'function' then
    --     action(entries)
    --     return
    -- end

    -- Convert FZF entries to locations
    local locations = vim.tbl_map(fzf_to_lsp, entries)

    -- Use the quickfix list to store remaining locations
    -- if #locations > 1 then
    --     vim.lsp.util.set_qflist(vim.lsp.util.locations_to_items(locations, offset_encoding))
    --     vim.cmd 'copen'
    --     vim.cmd 'wincmd p'
    -- end

    -- Apply user action to the first location
    -- if action then
    --     vim.cmd(fmt('%s %s', action, vim.uri_to_fname(locations[1].uri)))
    -- end

    -- Jump to the first location
    jump_to_location(locations[1])
end

local function jump_to_location(location)
    vim.lsp.util.jump_to_location(location, offset_encoding)

    -- if type(opts.callback) == 'function' then
    --     opts.callback()
    -- end
end

-- Custom lsp handler for document symbols
function M.fuzzy_symbol_handler(err, result, ctx, config)
    if err then
        return echo('ErrorMsg', err.message)
    end

    if not vim.g.loaded_fzf then
        return echo('WarningMsg', 'FZF is not loaded')
    end

    local items = vim.lsp.util.symbols_to_items(result, ctx.bufnr)
    local source = vim.tbl_map(lsp_to_fzf, items)
    local options =  {
        '--ansi',
        '--delimiter', '\' \'',
        '--with-nth=1..3',
        '--nth=3',
        '--preview-window', fzf_preview_window_option,
    }

    vim.list_extend(options, vim.fn['fzf#vim#with_preview']({ placeholder = '{4}:{5}' }).options)

    local opts = vim.fn['fzf#wrap']({ source = source, options = options })
    opts['sink*'] = jump

    print(vim.inspect(opts.options))

    vim.fn['fzf#run'](opts)
end

return M
