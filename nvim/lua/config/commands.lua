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
vim.api.nvim_create_user_command("Term", "<mods> new | startinsert | term <args>", {
    bang = true,
    nargs = "*",
})

-- Highlight git merge conflict markers
vim.cmd([[match ErrorMsg '\v^(\<|\=|\>){7}([^\=].+)?$']])

vim.cmd.packadd("cfilter")

vim.api.nvim_create_user_command("Messages", function(args)
    local lines = vim.api.nvim_exec2("messages", { output = true }).output

    vim.cmd(args.mods and (args.mods .. " new") or "new")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
    vim.cmd("setlocal buftype=nofile bufhidden=wipe nobuflisted")
    vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>bd!<CR>", { noremap = true, silent = true })
end, {})
