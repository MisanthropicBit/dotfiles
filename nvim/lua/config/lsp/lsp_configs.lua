local runtime_path = vim.split(package.path, ";")

require("neodev").setup({
    lspconfig = false,
})

table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

vim.g.lsp_configs = {
    {
        condition = function()
            return vim.fn.executable("clangd-mp-11") == 1
        end,
        name = "clangd",
        config = {
            cmd = { "clangd-mp-11" },
        }
    },
    { name = "tsserver" },
    { name = "sqlls" },
    {
        condition = function()
            return vim.fn.executable("lua-language-server") == 1
        end,
        name = "lua_ls",
        config = {
            before_init = require("neodev.lsp").before_init,
            settings = {
                Lua = {
                    runtime = {
                        version = "LuaJIT",
                        path = runtime_path,
                    },
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        library = {
                            vim.env.VIMRUNTIME,
                            vim.fn.expand("~/.vim-plug/neotest/lua"),
                            vim.fn.expand("~/.vim-plug/plenary.nvim/lua"),
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
        },
    },
    {
        name = "jsonls",
        config = {
            filetypes = { "json", "jsonc" },
            flags = {
                debounce_text_changes = 500,
            },
            snippets = true,
        },
    },
}

local function setup_lsp_server(server_config)
    local condition = server_config.condition

    if condition ~= nil and not condition() then
        return
    end

    local server_setup = require("lspconfig")[server_config.name]

    server_setup.setup(server_config.config or {})
end

for _, lsp_config in ipairs(vim.g.lsp_configs) do
    setup_lsp_server(lsp_config)
end
