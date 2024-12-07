local icons = require("config.icons")

local render = function(f)
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
                local no_oil = vim.fn.trim(info.buf_name:sub(7), "/", 2)
                local head = vim.fn.fnamemodify(no_oil, ":h") .. "/"
                local tail = vim.fn.fnamemodify(no_oil, ":t")

                f.add(vim.fn.pathshorten(head, 2) .. tail)
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
