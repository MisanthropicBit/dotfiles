return {
    src = "https://www.github.com/nvimtools/none-ls.nvim",
    data = {
        config = function(null_ls)
            local sources = {}

            local builtins = {
                eslint_d = {
                    require("none-ls.formatting.eslint_d").with({
                        timeout = 15000,
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
                selene = {
                    null_ls.builtins.diagnostics.selene.with({
                        command = "/Users/alexb/.cargo/bin/selene",
                    }),
                },
                stylua = { null_ls.builtins.formatting.stylua },
            }

            for builtin, config in pairs(builtins) do
                if vim.fn.executable(builtin) == 1 then
                    vim.list_extend(sources, config)
                end
            end

            null_ls.setup({ sources = sources })
        end,
    },
}
