local icons = require("config.icons")

local render = function(f)
    local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })

    f.add(" ")
    f.add({ " " .. icons.diagnostics.error .. errors, fg = "#e86671" })
    f.add({ " " .. icons.diagnostics.warn .. warnings, fg = "#e5c07b"})
    f.add("   ")

    f.make_tabs(function(info)
        f.add({ icons.lines.vertical .. " " })

        if info.filename then
            f.add(info.modified and icons.git.modified)
            f.add(info.filename)
            f.add({
                " " .. f.icon(info.filename),
                fg = info.current and f.icon_color(info.filename) or nil
            })
        else
            f.add(info.modified and icons.git.modified)
        end

        f.add({ "  " })
    end)
end

require("tabline_framework").setup({ render = render })
