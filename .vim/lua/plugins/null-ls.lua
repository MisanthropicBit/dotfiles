local null_ls = require('null-ls')

null_ls.setup{
    sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.eslint_d.with({
            condition = function(utils)
                return utils.root_has_file({ '.eslintrc' })
            end
        }),
        null_ls.builtins.code_actions.eslint_d,
    }
}
