return {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvimtools/none-ls-extras.nvim" },
    config = function()
        local null_ls = require("null-ls")
        local sources = {}

        local builtins = {
            eslint_d = {
                require("none-ls.formatting.eslint_d").with({
                    timeout = 10000,
                    extra_filetypes = { "yaml" },
                }),
                require("none-ls.code_actions.eslint_d").with({
                    extra_filetypes = { "yaml" },
                }),
                require("none-ls.diagnostics.eslint_d").with({
                    extra_filetypes = { "yaml" },
                }),
            },
            jq = { require("none-ls.formatting.jq") },
            selene = { null_ls.builtins.diagnostics.selene.with({
                command = "/Users/alexb/.cargo/bin/selene",
            }) },
            stylua = { null_ls.builtins.formatting.stylua },
        }

        for builtin, config in pairs(builtins) do
            if vim.fn.executable(builtin) == 1 then
                vim.list_extend(sources, config)
            end
        end

        null_ls.setup({ sources = sources })

        local function null_ls_command(command_func)
            return function()
                local null_ls_client

                for _, client in ipairs(vim.lsp.get_clients()) do
                    if client.name == "null-ls" then
                        null_ls_client = client
                    end
                end

                if not null_ls_client then
                    return
                end

                command_func(null_ls_client)
            end
        end

        local function null_ls_stop(client)
            if not client.is_stopped() then
                client.stop()
            end
        end

        local function null_ls_restart(client)
            null_ls_stop(client)
            vim.lsp.start(client.config)
        end

        vim.api.nvim_create_user_command("NullLsStop", null_ls_command(null_ls_stop), {})
        vim.api.nvim_create_user_command("NullLsRestart", null_ls_command(null_ls_restart), {})
    end,
}
