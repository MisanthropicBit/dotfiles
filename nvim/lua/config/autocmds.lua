local autocmds = {}

local augroup = vim.api.nvim_create_augroup("config", { clear = true })

if vim.fn.exists("g:last_tab") == 0 then
    vim.g.last_tab = vim.fn.tabpagenr()
end

---@param event string | string[]
---@param options table
autocmds.create_config_autocmd = function(event, options)
    vim.api.nvim_create_autocmd(event, vim.tbl_extend("force", { group = augroup }, options))
end

autocmds.create_config_autocmd("TabLeave", {
    pattern = "*",
    callback = function()
        vim.g.last_tab = vim.fn.tabpagenr()
    end,
})

-- autocmds.create_config_autocmd("VimResized", {
--     pattern = "*",
--     command = "tabdo wincmd =",
-- })

-- nvim_create_autocmd("InsertEnter", {
--     pattern = "*",
--     callback = function()
--         vim.opt.listchars:append({ "trail:⌴", "nbsp:¬" })
--     end,
-- })

-- nvim_create_autocmd("InsertLeave", {
--     pattern = "*",
--     callback = function()
--         vim.opt.listchars:remove({ "trail:⌴", "nbsp:¬" })
--     end,
-- })

autocmds.create_config_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = "*.fsproj",
    command = "setlocal ft=xml",
})

autocmds.create_config_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.html", "*.yml", "*.json" },
    command = "setlocal sw=2",
})

autocmds.create_config_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = ".eslintrc",
    command = "setlocal ft=json",
})

autocmds.create_config_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.highlight.on_yank({
            higroup = "IncSearch",
            timeout = 40,
        })
    end,
})

autocmds.create_config_autocmd("TermOpen", {
    command = "setlocal signcolumn=no nospell",
})

autocmds.create_config_autocmd("TermClose", {
    callback = function()
        if vim.v.event.status == 0 then
            vim.api.nvim_buf_delete(0, {})
        end
    end,
})

autocmds.create_config_autocmd("Colorscheme", {
    callback = function(event)
        -- Better highlights for window separators when statusline is global
        if vim.o.laststatus == 3 then
            local hl_options = { link = "Keyword", default = false }

            vim.api.nvim_set_hl(0, "VertSplit", hl_options)
            vim.api.nvim_set_hl(0, "WinSeparator", hl_options)
        end

        if event.match == "calvera" then
            vim.cmd([[silent hi! link IblIndent Comment]])
        end
    end,
})

autocmds.create_config_autocmd("FileType", {
    pattern = "neotest-output-panel",
    callback = function()
        vim.wo.winfixheight = true
    end,
})

return autocmds
