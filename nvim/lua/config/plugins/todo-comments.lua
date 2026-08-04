---@type config.PluginSpec
return {
    src = "https://www.github.com/folke/todo-comments.nvim",
    version = "31e3c38ce9b29781e4422fc0322eb0a21f4e8668",
    data = {
        config = function(todo_comments)
            local map = require("config.map")
            local icons = require("config.icons")

            todo_comments.setup({
                keywords = {
                    IMPORTANT = "WARN",
                    FIX = {
                        icon = icons.misc.alarm .. " ",
                    },
                    DEBUG = "TEST",
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
        end,
    },
}
