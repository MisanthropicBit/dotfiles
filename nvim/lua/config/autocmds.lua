local autocmds = {}

local map = require("config.map")

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
    pattern = { "*.html", "*.yml", "*.json" },
    command = "setlocal sw=2",
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

-- Close terminals automatically if the process' exit code was zero
autocmds.create_config_autocmd("TermClose", {
    callback = function(event)
        -- Do not close fzf-lua or overseer task terminals automatically
        if vim.o.ft == "fzf" or vim.b[event.buf].overseer_task then
            return
        end

        if vim.v.event.status == 0 then
            vim.api.nvim_buf_delete(event.buf, {})
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

autocmds.create_config_autocmd("BufReadPost", {
    pattern = "/private/*/T/*/command-line.fish",
    desc = "Save changes and quit buffer when editing a command in fish",
    callback = function(event)
        map.n("q", "<cmd>x<cr>", { buffer = event.buf })
    end,
})

return autocmds
