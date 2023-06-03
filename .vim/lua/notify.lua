local notify = {}

local old_vim_notify = vim.notify
local osascript_cmd = "osascript -e 'display notification \"%s\" with title \"%s\"'"

---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
    if type(opts) == 'table' and opts.mac == true then
        local title = (opts.title or 'neovim')

        -- print(string.format(osascript_cmd, msg, title))
        vim.fn.system(string.format(osascript_cmd, msg, title))
    else
        old_vim_notify(msg, level, opts)
    end
end

return notify
