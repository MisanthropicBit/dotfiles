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
