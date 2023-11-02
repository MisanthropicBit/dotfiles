local map = require("config.map")

local function buf_toggle_diagnostics_messages()
    local bufnr = vim.api.nvim_get_current_buf()
    local disabled = not vim.diagnostic.is_disabled(bufnr)

    vim.diagnostic[disabled and "disable" or "enable"](bufnr)
end

map.leader(
    'n',
    'dm',
    buf_toggle_diagnostics_messages,
    { desc = "Toggle diagnostic messages in the current buffer" }
)

-- vim diagnostics filtering
-- Inspired by https://blob42.xyz/blog/neovim-diagnostic-filtering/

-- Save the original virtual text handler
local orig_diag_virt_handler = vim.diagnostic.handlers.virtual_text

local namespace = vim.api.nvim_create_namespace("filtered_diagnostics")
local levels = {
    ["Off"] = 0,
    ["Error"] = vim.diagnostic.severity.ERROR,
    ["Warn"] = vim.diagnostic.severity.WARN,
    ["Info"] = vim.diagnostic.severity.INFO,
    ["Hint"] = vim.diagnostic.severity.HINT,
}
local diagnostics_visible = true

local function filter_diagnostics(diagnostics, level)
    return vim.tbl_filter(function(diagnostic)
        return diagnostic.severity <= level
    end, diagnostics)
end

local function set_diagnostics_level(level)
    vim.diagnostic.handlers.virtual_text = {
        show = function(_, bufnr, _, options)
            local diagnostics = vim.diagnostic.get(bufnr)
            local filtered_diagnostics = filter_diagnostics(diagnostics, level)
            print(#filtered_diagnostics)

            local namespaces = vim.diagnostic.get_namespaces()

            for ns, _ in pairs(namespaces) do
                orig_diag_virt_handler.show(ns, bufnr, filtered_diagnostics, options)
            end
        end,
        hide = function(_, bufnr)
            local namespaces = vim.diagnostic.get_namespaces()

            for ns, _ in pairs(namespaces) do
                orig_diag_virt_handler.hide(ns, bufnr)
            end
        end
    }

    vim.diagnostic.hide(nil, 0)
    local diagnostics = vim.diagnostic.get(0)

    if #diagnostics > 0 then
        -- Display the filtered diagnostics since all diagnostics are turned
        -- off as a baseline. The registered handler is usually only executed
        -- after a save or insert event
        local filtered_diagnostics = filter_diagnostics(diagnostics, level)

        vim.diagnostic.show(namespace, 0, filtered_diagnostics)
    end
end

local function prompt_level()
    local selected_level = nil

    vim.ui.select(vim.tbl_keys(levels), { prompt = "Set level to? " }, function(item)
        selected_level = item
    end)

    if selected_level ~= nil then
        set_diagnostics_level(levels[selected_level])
    end
end

local function toggle_diagnostics()
    diagnostics_visible = not diagnostics_visible

    vim.diagnostic[diagnostics_visible and "show" or "hide"]()
end

map.leader("n", "dl", prompt_level, { desc = "Set diagnostics level via a prompt" })
map.leader("n", "dt", toggle_diagnostics, { desc = "Toggle global diagnostics" })

vim.api.nvim_create_user_command(
    "SetDiagnosticsLevel",
    prompt_level,
    {
        nargs = "?",
        complete = function(_, _, _)
            return vim.tbl_keys(levels)
        end,
    }
)
