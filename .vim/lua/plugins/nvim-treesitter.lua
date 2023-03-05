require('nvim-treesitter.configs').setup{
    ensure_installed = {
        'cpp',
        'fish',
        'javascript',
        'json',
        'python',
        'typescript',
        'vim',
        'lua',
    },
    sync_install = false,
    auto_install = true,
    ignore_install = {},
    highlight = {
        enable = true,
        disable = {},
        additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<cr>',
            node_incremental = '<cr>',
            scope_incremental = '<s-cr>',
            node_decremental = '<bs>',
        }
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                -- ['ac'] = '@class.outer',
                -- ['ic'] = { query = '@class.inner', desc = 'Select inner part of a class region' },
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['an'] = '@number',
                ['in'] = '@number',
                ['ag'] = '@comment.outer',
                ['ig'] = '@comment.outer',
                ['ac'] = '@conditional.outer',
                ['ic'] = '@conditional.inner',
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ['<localleader>al'] = '@parameter.inner',
            },
            swap_previous = {
                ['<localleader>ah'] = '@parameter.inner',
            },
        },
        -- move = {
        --     enable = true,
        --     set_jumps = true,
        --     goto_next_start = {
        --         ['<f'] = '@function.outer',
        --     },
        --     goto_previous_start = {
        --         ['>f'] = '@function.outer',
        --     },
        -- },
    },
}

-- Unmap incremental selection inside the command-line window
vim.api.nvim_create_autocmd('CmdwinEnter', '<cmd>nunmap <buffer> <cr>')
