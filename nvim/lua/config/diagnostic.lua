local icons = require("config.icons")
local map = require("config.map")

---@param severity "hint" | "info" | "warn" | "error"
---@return string
local function get_hl_from_severity(severity)
    return "DiagnosticSign" .. severity:sub(1, 1):upper() .. severity:sub(2)
end

local severity_to_name = {
    "error",
    "warn",
    "info",
    "hint",
}

local sign_config = {
    text = {},
    numhl = {},
    linehl = {},
}

for type, icon in pairs(icons.diagnostics) do
    local severity = vim.diagnostic.severity[type:upper()]
    local hl = get_hl_from_severity(type)

    sign_config.text[severity] = icon
    sign_config.numhl[severity] = hl
    sign_config.linehl[severity] = hl
end

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

            return icon .. " ", get_hl_from_severity(name)
        end,
    },
    signs = sign_config,
    underline = true,
    severity_sort = true,
})

---Create a function that will jump to a diagnostic of a certain severity
---@param count integer
---@param severity? integer
---@return function
local function goto_diagnostic_wrapper(count, severity)
    return function()
        vim.diagnostic.jump({ count = count, float = true, severity = severity })
    end
end

local error_severity = vim.diagnostic.severity.ERROR

-- Diagnostic mappings
map.n.leader("lp", goto_diagnostic_wrapper(-1), "Jump to previous diagnostic")
map.n.leader("ln", goto_diagnostic_wrapper(1), "Jump to next diagnostic")
map.n.leader("ep", goto_diagnostic_wrapper(-1, error_severity), "Jump to previous diagnostic error")
map.n.leader("en", goto_diagnostic_wrapper(1, error_severity), "Jump to next diagnostic error")
map.n.leader("ll", vim.diagnostic.open_float, "Open diagnostic float")
map.n.leader("dq", vim.diagnostic.setqflist, "Open diagnostics in location list")
map.n.leader("dQ", function()
    vim.diagnostic.setqflist({
        severity = vim.diagnostic.severity.ERROR,
    })
end, "Open only error-level diagnostics in location list")
