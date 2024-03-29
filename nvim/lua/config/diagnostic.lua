local icons = require("config.icons")
local map = require("config.map")

local severity_to_name = {
    "error",
    "warn",
    "info",
    "hint",
}

vim.diagnostic.config({
    virtual_text = {
        prefix = icons.text.bullet,
        source = true,
        spacing = 1,
    },
    float = {
        source = true,
        header = "",
        prefix = function(diagnostic)
            local name = severity_to_name[diagnostic.severity]
            local icon = icons.diagnostics[name]

            return icon .. " ", "DiagnosticSign" .. name:sub(1, 1):upper() .. name:sub(2)
        end,
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

-- Diagnostic mappings
map.n.leader("lp", vim.diagnostic.goto_prev, "Jump to previous diagnostic")
map.n.leader("ln", vim.diagnostic.goto_next, "Jump to next diagnostic")
map.n.leader(
    "ep",
    goto_diagnostic_wrapper(vim.diagnostic.goto_prev, error_severity),
    "Jump to previous diagnostic error"
)
map.n.leader(
    "en",
    goto_diagnostic_wrapper(vim.diagnostic.goto_next, error_severity),
    "Jump to next diagnostic error"
)
map.n.leader("ll", vim.diagnostic.open_float, "Open diagnostic float")
map.n.leader("dq", vim.diagnostic.setqflist, "Open diagnostics in location list")
map.n.leader("dQ", function()
    vim.diagnostic.setqflist({
        severity = vim.diagnostic.severity.ERROR,
    })
end, "Open only error-level diagnostics in location list")
