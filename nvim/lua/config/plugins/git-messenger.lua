---@type config.PluginSpec
return {
    src = "https://www.github.com/rhysd/git-messenger.vim",
    version = "fd124457378a295a5d1036af4954b35d6b807385",
    data = {
        config = function()
            vim.g.git_messenger_conceal_word_diff_marker = true
            vim.g.git_messenger_always_into_popup = true

            local autocmds = require("config.autocmds")
            local map = require("config.map")

            autocmds.create_config_autocmd("FileType", {
                pattern = { "gitmessengerpopup" },
                callback = function(event)
                    map.n("<c-h>", "o", { buffer = event.buf, remap = true })
                    map.n("<c-l>", "O", { buffer = event.buf, remap = true })
                end,
            })
        end,
    },
}
