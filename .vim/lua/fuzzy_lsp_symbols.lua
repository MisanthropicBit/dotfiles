local M = {}

local ansi = require('ansi')
local lsp_common = require('lsp_common')

local kind_icons = lsp_common.kind_icons
local kind_to_hl = lsp_common.kind_to_hl
local kind_icons_keys = vim.tbl_keys(kind_icons)
local fzf_preview_window_option = vim.g.fzf_preview_window or 'right:+{2}-/2'

local function echo(hlgroup, msg)
    vim.cmd(string.format('echohl %s', hlgroup))
    vim.cmd(string.format('echom "%s"', msg))
    vim.cmd('echohl None')
end

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
        ansi_rgb_table[kind] = ansi.highlight_to_rgb_ansi(kind_to_hl[kind] or 'Label')
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
    -- TODO: termguicolors not necessarily set here
    local has_gui_colors = 2 -- vim.o.termguicolors and 2 or 1

    for _, kind in pairs(kinds) do
        color_table[kind] = ansi_codes[has_gui_colors][kind]
    end

    return color_table
end

local kind_colors = construct_lsp_symbol_colors(kind_icons_keys, ansi)

local function process_lsp_item(item)
    local result = vim.split(item.text, '%]')
    local kind, item_name = string.sub(result[1], 2), string.sub(result[2], 2)

    return {
        item = item,
        name = item_name,
        kind = kind,
    }
end

local function lsp_to_fzf(item)
    local result = process_lsp_item(item)
    local kind_icon = kind_icons[result.kind] or result.kind

    return string.format(
        '%s%s %s%s %s %s %d %d',
        kind_colors[result.kind] or '',
        kind_icon,
        result.kind,
        '\x1b[0m',
        result.name,
        item.filename,
        item.lnum,
        item.col
    )
end

local function fzf_to_lsp(entry)
    local entry_data = vim.split(entry, ' ')

    local uri = vim.uri_from_fname(vim.fn.fnamemodify(vim.fn.expand(entry_data[5]), ':p'))
    local position = {
        line = tonumber(entry_data[6]) - 1,
        character = tonumber(entry_data[7]) - 1
    }

    return {
        uri = uri,
        range = { start = position, ['end'] = position },
    }
end

local function jump_to_location(location, action)
    if action then
        vim.cmd(string.format('%s %s', action, vim.uri_to_fname(location.uri)))
    end

    -- TODO: Handle offset_encoding
    vim.lsp.util.jump_to_location(location, 'utf-8')

    vim.cmd('normal! zz')
end

local function cmd_for_key(key)
    return vim.g.fzf_action[key] or nil
end

local function jump(entries)
    if not entries or #entries < 2 then
        return
    end

    -- Retrieve user action
    local key = table.remove(entries, 1)

    -- Convert FZF entries to locations
    local locations = vim.tbl_map(fzf_to_lsp, entries)

    -- Jump to the first location
    jump_to_location(locations[1], cmd_for_key(key))
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

    if vim.b.fuzzy_symbol_handler_command_arg ~= nil then
        items = vim.tbl_filter(function(item)
            local result = process_lsp_item(item)

            return string.lower(result.kind) == vim.b.fuzzy_symbol_handler_command_arg.args
        end, items)
    end

    vim.b.fuzzy_symbol_handler_command_arg = nil

    if #items == 0 then
        return echo('WarningMsg', 'No results')
    end

    local source = vim.tbl_map(lsp_to_fzf, items)
    local options =  {
        '--ansi',
        '--delimiter', ' ',
        '--with-nth=1..4',
        '--nth=4',
        '--preview-window', fzf_preview_window_option,
    }

    vim.list_extend(options, vim.fn['fzf#vim#with_preview']({ placeholder = '{5}:{6}' }).options)

    local opts = vim.fn['fzf#wrap']({ source = source, options = options })
    opts['sink*'] = jump

    vim.fn['fzf#run'](opts)
end

return M
