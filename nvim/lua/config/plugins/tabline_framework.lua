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
        f.add(info.modified and icons.git.modified)

        if info.filename then
            f.add(info.filename)
            f.add({
                " " .. f.icon(info.filename),
                fg = info.current and f.icon_color(info.filename) or nil
            })
        else
            if vim.startswith(info.buf_name, "fugitive://") then
                f.add("git status")
                f.add({
                    " " .. f.icon("git"),
                    fg = info.current and f.icon_color("git") or nil
                })
            elseif vim.startswith(info.buf_name, "oil://") then
                f.add("oil")
                f.add({ " " .. icons.files.oil })
            elseif info.buf_name == "" then
                f.add("New file")
                f.add({ " " .. icons.files.new })
            end
        end

        f.add({ "  " })
    end)
end

require("tabline_framework").setup({ render = render })
