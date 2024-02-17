local map = require("config.map")

local function normal_cmd_with_restore_window(cmd)
    return function()
        local winview = vim.fn.winsaveview()

        vim.cmd(('<cmd>silent execute "normal %s"'):format(cmd))

        vim.fn.winrestview(winview)
    end
end

map.n("cvv", function()
    vim.cmd("vert G commit")
    vim.cmd("norm! O")
    vim.cmd.startinsert()
end, { buffer = true })

map.n("-", normal_cmd_with_restore_window([[\<Plug>fugitive:-zz]]), { buffer = true })

-- I go to unstaged files way more often than untracked files
map.n("gu", "<Plug>fugitive:gU", { buffer = true })
map.n("gU", "<Plug>fugitive:gu", { buffer = true })

map.n("s", "<Plug>fugitive:o", { buffer = true })
map.n("v", "<Plug>fugitive:gO", { buffer = true })
map.n("t", "<Plug>fugitive:O", { buffer = true })
