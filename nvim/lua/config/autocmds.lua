local augroup = vim.api.nvim_create_augroup("config", { clear = true })

if vim.fn.exists("g:last_tab") == 0 then
    vim.g.last_tab = vim.fn.tabpagenr()
end

local create_autocmd = vim.api.nvim_create_autocmd

create_autocmd("TabLeave", {
    group = augroup,
    pattern = "*",
    callback = function()
        vim.g.last_tab = vim.fn.tabpagenr()
    end,
})

create_autocmd("VimResized", {
    group = augroup,
    pattern = "*",
    command = "tabdo wincmd =",
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

create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup,
    pattern = "*.fsproj",
    command = "setlocal ft=xml",
})

create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup,
    pattern = { "*.html", "*.yml", "*.json" },
    command = "setlocal sw=2",
})

create_autocmd({ "BufRead", "BufNewFile" }, {
    group = augroup,
    pattern = ".eslintrc",
    command = "setlocal ft=json",
})

create_autocmd("TextYankPost", {
    group = augroup,
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 40,
        })
    end,
})

create_autocmd("TermOpen", {
    group = augroup,
    command = "setlocal signcolumn=no nospell",
})

create_autocmd("TermClose", {
    group = augroup,
    callback = function()
        if vim.v.event.status == 0 then
            vim.api.nvim_buf_delete(0, {})
        end
    end,
})
