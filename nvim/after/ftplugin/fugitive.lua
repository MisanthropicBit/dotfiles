local map = require("config.map")

local function normal_cmd_with_restore_window(cmd)
    return function()
        local winview = vim.fn.winsaveview()

        vim.cmd(('silent execute "normal %s"'):format(cmd))

        vim.fn.winrestview(winview)
    end
end

local function prepare_git_commit_message(mods)
    return function()
        vim.cmd((mods and (mods .. " ") or "") .. "G commit")
        vim.cmd("norm! O")
        vim.cmd.startinsert()
    end
end

map.n("cc", prepare_git_commit_message(), { buffer = true })
map.n("cvv", prepare_git_commit_message("vert"), { buffer = true })
map.n("-", normal_cmd_with_restore_window([[\<Plug>fugitive:-zz]]), { buffer = true })

-- I go to unstaged files way more often than untracked files
map.n("gu", "<Plug>fugitive:gU", { buffer = true })
map.n("gU", "<Plug>fugitive:gu", { buffer = true })

map.n("s", "<Plug>fugitive:o", { buffer = true })
map.n("v", "<Plug>fugitive:gO", { buffer = true })
map.n("t", "<Plug>fugitive:O", { buffer = true })

map.n.leader("ms", "<cmd>Gsplit origin/master:%")
map.n.leader("mv", "<cmd>Gvsplit origin/master:%")
map.n.leader("mt", "<cmd>Gtabedit origin/master:%")
