vim.api.nvim_create_user_command("Grep", [[execute 'silent grep! <args> | copen']], {
    nargs = "+",
})

-- vim supports a 'vertical'/'tab' prefix before :terminal, but neovim
-- currently doesn't
vim.api.nvim_create_user_command("Term", "<mods> new | startinsert | term <args>", {
    bang = true,
    nargs = "*",
})
