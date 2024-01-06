local input = {}

local map = require("config.map")
local icons = require("config.icons")

local old_vim_ui_input

---@alias config.ui.Border "none" | "single" | "double" | "rounded" | "solid" | "shadow" | string[]

---@class config.ui.Size
---@field width string | integer
---@field height string | integer

---@class config.ui.InputOptions
---@field relative "editor" | "win" | "cursor" | "mouse"
---@field prompt string?
---@field default string?
---@field filetype string?
---@field enter boolean?
---@field border config.ui.Border?
---@field row (string | integer)?
---@field col (string | integer)?
---@field size ("fit" | config.ui.Size)?

-- TODO: Add footer in 0.10
local default_win_config = {
    relative = "editor",
    title = {{ " Input", "Title" }},
    title_pos = "left",
    noautocmd = true,
    prompt = icons.misc.prompt .. "_ ",
    default = nil,
    filetype = vim.bo.filetype,
    enter = true,
    enter_insert = true,
    multiline = false,
    border = "rounded",
    row = "center",
    col = "center",
    size = {
        width = "auto",
        height = 1,
    },
    anchor = "NW",
    keymaps = {
        confirm = "<enter>",
        quit = "<c-c>",
    },
    focusable = true,
    style = "minimal",
    zindex = 10,
    win_options = {
        wrap = false,
        number = false,
        relativenumber = false,
        cursorline = false,
        signcolumn = "no",
        foldenable = false,
        spell = false,
        list = false,
    },
    buffer_options = {
        buftype = "nofile",
        bufhidden = "wipe",
        buflisted = false,
    }
}


local function get_percentage(value)
    local match = value:match("(%d+)%%")

    if match then
        return tonumber(match) / 100.0
    end

    return nil
end

local function resolve_position(pos, relative, dimension, max)
    if relative == "cursor" then
        local win_row, win_col = unpack(vim.fn.win_screenpos(0))

        return {
            lnum = vim.fn.winline() + win_row - 1,
            col = vim.fn.wincol() + win_col - 1,
        }
    end

    local resolved_pos = pos

    if type(pos) == "string" then
        if pos == "center" then
            resolved_pos = max / 2
        else
            local percentage = get_percentage(pos)

            if percentage then
                resolved_pos = percentage * max
            else
                error(("Unsupported position string: '%s'"):format(pos))
            end
        end
    end

    return resolved_pos - dimension / 2
end

---@param dimension number
---@param max integer
local function resolve_dimension(dimension, max)
    if type(dimension) == "string" then
        if dimension == "auto" then
            return math.floor(max * 0.15)
        else
            local percentage = get_percentage(dimension)

            if percentage then
                return math.floor(percentage)
            end

            error(("Unsupported position string: '%s'"):format(dimension))
        end
    else
        return math.floor(dimension)
    end
end

local function resolve_size(size)
    return {
        width = resolve_dimension(size.width, vim.o.columns),
        height = resolve_dimension(size.height, vim.o.lines),
    }
end

local function resolve_options(options)
    local _options = vim.tbl_extend("force", default_win_config, options or {})

    local size = resolve_size(_options.size)
    local row, col

    if _options.relative == "cursor" then
        row, col = 1, -1
    end

    local win_config = {
        relative = _options.relative,
        title = _options.title,
        title_pos = _options.title_pos,
        noautocmd = _options.noautocmd,
        border = _options.border,
        row = row or resolve_position(_options.row, _options.relative, size.height, vim.o.lines),
        col = col or resolve_position(_options.col, _options.relative, size.width, vim.o.columns),
        width = size.width,
        height = size.height,
        focusable = _options.focusable,
        style = _options.style,
        zindex = _options.zindex,
        anchor = _options.anchor,
    }

    return win_config, _options
end

local function set_win_buffer_options(win_id, buffer, win_options, buffer_options)
    for option, value in pairs(win_options) do
        vim.api.nvim_win_set_option(win_id, option, value)
    end

    -- Set default buffer options
    for option, value in pairs(buffer_options) do
        vim.api.nvim_buf_set_option(buffer, option, value)
    end

    -- Set user options last so they take priority
    for option, value in pairs(win_options) do
        vim.api.nvim_win_set_option(win_id, option, value)
    end

    vim.api.nvim_win_set_var(win_id, "config.ui.input", true)
end

--- Dropin replacement for vim.ui.input
---@param options config.ui.InputOptions?
---@param on_confirm fun(input: string?): nil
function input.open(options, on_confirm)
    local buffer = vim.api.nvim_create_buf(false, true)

    -- Create floating window
    local win_config, resolved_options = resolve_options(options)
    local win_id = vim.api.nvim_open_win(buffer, resolved_options.enter, win_config)

    -- Set buffer contents
    local lines = {}

    if resolved_options.prompt then
        table.insert(lines, resolved_options.prompt)
    end

    if resolved_options.default then
        table.insert(lines, resolved_options.default)
    end

    if #lines > 0 then
        vim.api.nvim_buf_set_lines(buffer, 0, -1, true, { table.concat(lines, "") })
    end

    -- Setup floating window options
    set_win_buffer_options(win_id, buffer, resolved_options.win_options, resolved_options.buffer_options)

    -- Keymaps
    local function close_window()
        pcall(vim.api.nvim_win_close, win_id, true)

        if resolved_options.enter and resolved_options.enter_insert then
            vim.cmd([[stopinsert]])
        end
    end

    local function submit(map_mode)
        map_mode(resolved_options.keymaps.confirm, function()
            local submit_lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, true)

            -- Strip prompt from input (only works if the user doesn't edit the prompt)
            if resolved_options.prompt then
                submit_lines[1] = submit_lines[1]:sub(#resolved_options.prompt + 1)
            end

            close_window()
            on_confirm(table.concat(submit_lines, "\n"))
        end, "")
    end

    submit(map.n)
    map.n(resolved_options.keymaps.quit, close_window, "")

    if not resolved_options.multiline then
        -- If the prompt is not multiline, the user can also submit via insert-mode enter
        submit(map.i)
    else
        map.i("<cr>", function()
            local key = vim.api.nvim_replace_termcodes("<cr>", true, false, true)
            vim.api.nvim_feedkeys(key, "n", false)

            local cur_win_config = vim.api.nvim_win_get_config(win_id)
            vim.api.nvim_win_set_config(win_id, { height = cur_win_config.height + 1 })
        end)
    end

    -- Autocommands
    vim.api.nvim_create_autocmd("WinLeave", {
        -- group = "",
        buffer = buffer,
        once = true,
        callback = function()
            close_window()

            return true -- Delete the autocommand
        end,
    })

    if resolved_options.enter and resolved_options.enter_insert then
        vim.cmd([[startinsert!]])
    end
end

--- Default input prompt
---@param options table<string, any>
---@param on_confirm fun(input: string?): nil
function input.open_default(options, on_confirm)
    input.open(options, on_confirm)
end

--- Open an input prompt at cursor
---@param options table<string, any>
---@param on_confirm fun(input: string?): nil
function input.open_at_cursor(options, on_confirm)
    local merged_options = vim.tbl_extend("force", options, {
        relative = "cursor",
    })

    input.open(merged_options, on_confirm)
end

--- Open an input prompt at cursor with default options
---@param options table<string, any>
---@param on_confirm fun(input: string?): nil
function input.open_default_at_cursor(options, on_confirm)
    input.open_at_cursor(vim.tbl_extend("force", default_win_config, options), on_confirm)
end

function input.register_default()
    old_vim_ui_input = vim.ui.input

    ---@diagnostic disable-next-line: duplicate-set-field
    vim.ui.input = function(options, on_confirm)
        if options and options.prompt == "New Name: " then
            -- This is an lsp rename, open at cursor instead
            input.open_default_at_cursor(vim.tbl_extend("force", options, {
                prompt = "",
                title = "New name"
            }), on_confirm)
        else
            input.open_default(options, on_confirm)
        end
    end
end

function input.get_builtin()
    return old_vim_ui_input or vim.ui.input
end

return input
