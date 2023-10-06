local icons = require("config.icons")
local map = require("config.map")

local has_lspsaga, _ = pcall(require, "lspsaga")

vim.diagnostic.config({
    virtual_text = {
        prefix = '●',
        source = 'always',
        spacing = 1,
    },
    float = {
        source = "always",
    },
    signs = true,
    underline = true,
    severity_sort = true,
})

for type, icon in pairs(icons.diagnostics) do
    local hl = "DiagnosticSign" .. type:sub(1, 1):upper() .. type:sub(2)
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

---Create a function that will jump to a diagnostic of a certain severity
---@param func function
---@param severity integer
---@return function
local function goto_diagnostic_wrapper(func, severity)
    return function()
        func({ severity = severity })
    end
end

local error_severity = vim.diagnostic.severity.ERROR

-- Diagnostic methods for the right-hand side of lsp mappings
local diagnostics_methods = {
    goto_prev = vim.diagnostic.goto_prev,
    goto_next = vim.diagnostic.goto_next,
    goto_prev_error = goto_diagnostic_wrapper(vim.diagnostic.goto_prev, error_severity),
    goto_next_error = goto_diagnostic_wrapper(vim.diagnostic.goto_next, error_severity),
    open_float = vim.diagnostic.open_float,
}

-- Override select lsp methods and diagnostics functionality with lspsaga
if has_lspsaga then
    local function lspsaga_cmd(command)
        return ("<cmd>Lspsaga %s<cr>"):format(command)
    end

    local lspsaga_diagnostic = require("lspsaga.diagnostic")

    local lspsaga_goto_prev_error = function()
        lspsaga_diagnostic:goto_prev({ severity = error_severity })
    end

    local lspsaga_goto_next_error = function()
        lspsaga_diagnostic:goto_next({ severity = error_severity })
    end

    diagnostics_methods.goto_prev = lspsaga_cmd("diagnostic_jump_prev")
    diagnostics_methods.goto_next = lspsaga_cmd("diagnostic_jump_next")
    diagnostics_methods.goto_prev_error = lspsaga_goto_prev_error
    diagnostics_methods.goto_next_error = lspsaga_goto_next_error
    diagnostics_methods.open_float = lspsaga_cmd("show_line_diagnostics ++unfocus")
end

-- Diagnostic mappings
map.leader("n", "lp", diagnostics_methods.goto_prev, "Jump to previous diagnostic")
map.leader("n", "ln", diagnostics_methods.goto_next, "Jump to next diagnostic")
map.leader("n", "ep", diagnostics_methods.goto_prev_error, "Jump to previous diagnostic error")
map.leader("n", "en", diagnostics_methods.goto_next_error, "Jump to next diagnostic error")
map.leader("n", "ll", diagnostics_methods.open_float, "Open diagnostic float")
