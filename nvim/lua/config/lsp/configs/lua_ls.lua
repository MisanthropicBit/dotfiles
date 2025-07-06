local runtime_path = vim.split(package.path, ";")

require("neodev").setup({
    lspconfig = false,
})

table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

return {
    before_init = require("neodev.lsp").before_init,
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
                path = runtime_path,
            },
            diagnostics = {
                globals = { "hs", "vim" },
            },
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                    vim.fs.normalize("~/.hammerspoon/Spoons/EmmyLua.spoon/annotations"),
                },
                maxPreload = 3000,
                preloadFileSize = 50000,
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
        },
    },
}
