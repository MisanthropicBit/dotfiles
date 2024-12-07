local map = require("config.map")

local runtime_path = vim.split(package.path, ";")

require("neodev").setup({
    lspconfig = false,
})

table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")


local function organize_imports()
    local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
    }

    vim.lsp.buf.execute_command(params)
end

local lsp_configs = {
    clangd = {
        condition = function()
            return vim.fn.executable("clangd-mp-11") == 1
        end,
        config = {
            cmd = { "clangd-mp-11" },
        }
    },
    ts_ls = {
        config = {
            workspace_folders = {
                "/Users/aab/repos/node-backend",
                "/Users/aab/repos/api",
            },
            commands = {
                OrganizeImports = {
                    organize_imports,
                    description = "Organize, sort, and removed unused imports",
                }
            },
        },
        keymaps = {
            function()
                map.n.leader("oi", "<cmd>OrganizeImports<cr>", "Organize typescript imports")
            end
        }
    },
    sqlls = {},
    lua_ls = {
        condition = function()
            return vim.fn.executable("lua-language-server") == 1
        end,
        config = {
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
                            vim.fs.normalize("~/.vim-plug/neotest/lua"),
                            vim.fs.normalize("~/.vim-plug/plenary.nvim/lua"),
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
        },
    },
    jsonls = {
        config = {
            -- format = {
            --     enable = true,
            -- },
            -- flags = {
            --     debounce_text_changes = 500,
            -- },
            settings = {
                json = {
                    validate = {
                        enable = true,
                    },
                    schemas = {
                        {
                            description = "NPM configuration file",
                            fileMatch = { "package.json" },
                            name = "package.json",
                            url = "https://json.schemastore.org/package.json"
                        },
                        {
                            description = "TypeScript compiler configuration file",
                            fileMatch = { "tsconfig*.json" },
                            name = "tsconfig.json",
                            url = "https://json.schemastore.org/tsconfig.json"
                        },
                        {
                            description = "ESLint configuration files",
                            fileMatch = { ".eslintrc", ".eslintrc.json", ".eslintrc.yml", ".eslintrc.yaml" },
                            name = ".eslintrc",
                            url = "https://json.schemastore.org/eslintrc.json"
                        },
                        {
                            description = "Babel configuration file",
                            fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
                            name = "babelrc.json",
                            url = "https://json.schemastore.org/babelrc.json"
                        },
                    },
                },
            },
        },
    },
    yamlls = {
        condition = function()
            return vim.fn.executable("yaml-language-server") == 1
        end,
        -- See: https://www.arthurkoziel.com/json-schemas-in-neovim/
        config = {
            yaml = {
                validate = true,
                schemaStore = {
                    enable = false,
                    url = "",
                },
                schemas = {
                    ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/**/*.ya?ml",
                    ["https://json.schemastore.org/cloudbuild.json"] = "cloudbuild.ya?ml",
                    ["https://json.schemastore.org/kustomization.json"] = "kustomization.ya?ml",
                }
            },
            redhat = {
                telemetry = {
                    enabled = false
                }
            },
        },
    },
    marksman = {
        condition = function()
            return vim.fn.executable("marksman")
        end,
    }
}

local function setup_lsp_server(name, server_config)
    local condition = server_config.condition

    if condition ~= nil and not condition() then
        return
    end

    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local server_setup = require("lspconfig")[name]

    server_setup.setup(vim.tbl_deep_extend("force", server_config.config or {}, { capabilities = capabilities }))
end

for name, lsp_config in pairs(lsp_configs) do
    setup_lsp_server(name, lsp_config)
end

return lsp_configs
