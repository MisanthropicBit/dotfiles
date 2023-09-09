local augroup = vim.api.nvim_create_augroup("config", { clear = true })

if vim.fn.exists("g:last_tab") == 0 then
    vim.g.last_tab = vim.fn.tabpagenr()
end

local nvim_create_autocmd = vim.api.nvim_create_autocmd

nvim_create_autocmd("TabLeave", {
    group = augroup,
    pattern = "*",
    callback = function()
        vim.g.last_tab = vim.fn.tabpagenr()
    end,
})

nvim_create_autocmd("VimResized", {
    group = augroup,
    pattern = "*",
    command = "tabdo <cmd>wincmd =",
})

-- nvim_create_autocmd("InsertEnter", {
--     group = augroup,
--     pattern = "*",
--     callback = function()
--         vim.opt.listchars:append({ "trail:⌴", "nbsp:¬" })
--     end,
-- })

-- nvim_create_autocmd("InsertLeave", {
--     group = augroup,
--     pattern = "*",
--     callback = function()
--         vim.opt.listchars:remove({ "trail:⌴", "nbsp:¬" })
--     end,
-- })

nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup,
    pattern = "*.fsproj",
    command = "setlocal ft=xml",
})

-- nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--     group = augroup,
--     pattern = "*.fsproj",
--     command = "setlocal ft=xml",
-- })

nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup,
    pattern = { "*.html", "*.yml", "*.json" },
    command = "setlocal sw=2",
})

-- nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--     group = augroup,
--     pattern = "Dockerfile.*",
--     command = "setlocal ft=dockerfile",
-- })

nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup,
    pattern = ".eslintrc",
    command = "setlocal ft=json",
})

-- nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--     group = augroup,
--     pattern = ".*gitconfig",
--     command = "setlocal ft=gitconfig",
-- })

nvim_create_autocmd("TermOpen", {
    group = augroup,
    command = "setlocal signcolumn=no",
})

nvim_create_autocmd("TextYankPost", {
    group = augroup,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 40,
        })
    end,
})
