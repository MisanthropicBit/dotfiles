local todo_comments = require("todo-comments")

local map = require("config.map")

todo_comments.setup({
    sign_priority = (vim.g.gitgutter_sign_priority or 10) + 1,
    keywords = {
        IMPORTANT = "WARN",
        FIX = {
            icon = "󰢫 ",
        },
    },
})

local function jump_and_center(func)
    return function()
        func()
        vim.cmd.normal("zz")
    end
end

map.n.leader("dn", jump_and_center(todo_comments.jump_next), "Jump to next todo comment")
map.n.leader("dp", jump_and_center(todo_comments.jump_prev), "Jump to previous todo comment")
