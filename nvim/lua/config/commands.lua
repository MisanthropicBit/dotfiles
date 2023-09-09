vim.api.nvim_create_user_command("Grep", "<cmd>execute 'silent grep! <args> | copen'", {})

-- vim supports a 'vertical'/'tab' prefix before :terminal, but neovim
-- currently doesn't
vim.api.nvim_create_user_command("Term", "<mods> new | startinsert | term <args>", {
    bang = true,
    nargs = "*",
})
