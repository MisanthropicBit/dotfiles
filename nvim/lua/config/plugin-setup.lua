local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { import = "config.plugins" },
    },
    checker = {
        enabled = true,
        notify = false,
    },
    dev = {
        path = "~/projects",
        patterns = {
            "docs",
            "winmove",
            "warlock",
            "neotest-jest",
            "neotest-busted",
            "fzf-lua-ast-grep",
        },
        fallback = true,
    }
})
