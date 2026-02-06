local icons = require("config.icons")
local ui = require("config.ui")

vim.api.nvim_create_user_command("Grep", function()
    ui.input.open_default({
        title = "Grep for " .. icons.misc.prompt,
    }, function(input)
        local escaped, _ = input:gsub('([|"])', "\\%1")
        local command = ([[execute 'silent grep! "%s" | copen']]):format(escaped)

        vim.cmd(command)
    end)
end, {})

-- vim supports a 'vertical'/'tab' prefix before :terminal, but neovim
-- currently doesn't
vim.api.nvim_create_user_command("Term", function(args)
    local count = args.count

    vim.cmd(("%s%s new | startinsert | term %s"):format(args.mods, count > 0 and tostring(count) or "", args.args))
end, {
    bang = true,
    count = true,
    nargs = "*",
})

vim.api.nvim_create_user_command("Messages", function(args)
    local lines = vim.api.nvim_exec2("messages", { output = true }).output

    vim.cmd(args.mods and (args.mods .. " new") or "new")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
    vim.cmd("setlocal buftype=nofile bufhidden=wipe nobuflisted")
    vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true })
end, {})

vim.api.nvim_create_user_command("HttpCode", function(args)
    local arg = args.fargs[1]
    local http = require("config.utils.http")
    local http_code = http.is_supported_code(arg)

    if not http_code then
        vim.notify(("Not a valid or supported http code: '%s'"):format(arg))
        return
    end

    http.lookup_code(http_code)
end, {
    nargs = 1,
})
