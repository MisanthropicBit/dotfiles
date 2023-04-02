local plugins = {
    'boole',
    'bufferline',
    'dashboard',
    'fzf-lua',
    'goto-preview',
    'hex',
    'indent_blankline',
    'lsp_signature',
    'lspsaga',
    'neotest',
    'null-ls',
    'cmp',
    'dapui',
    'dap',
    'nvim-treesitter-playground',
    'nvim-treesitter',
    'trouble',
    'ts-node-action',
}

local loader = require('plugins.loader')

table.foreach(plugins, function(idx, value)
    loader.load(value)
end)
