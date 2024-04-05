require("config.plugins.vim-plugins.delimiteMate")
require("config.plugins.vim-plugins.git-messenger")
require("config.plugins.vim-plugins.linediff")
require("config.plugins.vim-plugins.vim-easy-align")
require("config.plugins.vim-plugins.vim-fugitive")
require("config.plugins.vim-plugins.vim-yank-window")

-- NOTE: The Plug commands MUST use single-quotes
vim.cmd([[
    call plug#begin('~/.vim-plug')

    " Adds help for vim-plug itself
    Plug 'junegunn/vim-plug'

    " Colorschemes
    Plug 'AlexvZyl/nordic.nvim'
    Plug 'EdenEast/nightfox.nvim'
    Plug 'askfiy/visual_studio_code'
    Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'hoprr/calvera-dark.nvim'
    Plug 'mellow-theme/mellow.nvim'
    Plug 'lmburns/kimbox'
    Plug 'maxmx03/fluoromachine.nvim'
    Plug 'projekt0n/caret.nvim'
    Plug 'ramojus/mellifluous.nvim'
    Plug 'rebelot/kanagawa.nvim'
    Plug 'ribru17/bamboo.nvim'
    Plug 'savq/melange'
    Plug 'shaunsingh/moonlight.nvim'
    Plug 'tiagovla/tokyodark.nvim'
    Plug 'LunarVim/horizon.nvim'
    Plug '~/projects/vim/warlock.nvim'

    if executable('node') && executable('yarn')
        Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install', 'for': ['markdown', 'vim-plug'] }
    else
        Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }
    endif

    Plug 'AndrewRadev/linediff.vim'
    Plug 'Konfekt/FastFold'
    Plug 'Raimondi/delimitMate'
    Plug 'andymass/vim-matchup'
    Plug 'arthurxavierx/vim-caser'
    Plug 'honza/vim-snippets'
    Plug 'junegunn/vim-easy-align'
    Plug 'mhinz/vim-startify'
    Plug 'rhysd/git-messenger.vim'
    Plug 'tommcdo/vim-exchange'
    Plug 'tpope/vim-abolish'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-git'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-rhubarb'

    Plug 'nat-418/boole.nvim'
    Plug 'nvimdev/dashboard-nvim'
    Plug 'MisanthropicBit/decipher.nvim'
    Plug 'sindrets/diffview.nvim'
    Plug 'rafamadriz/friendly-snippets'
    Plug 'ibhagwan/fzf-lua', { 'branch': 'main' }
    Plug 'rmagatti/goto-preview'
    Plug 'lukas-reineke/headlines.nvim'
    Plug 'stefanlogue/hydrate.nvim'
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'ray-x/lsp_signature.nvim'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'L3MON4D3/LuaSnip', { 'tag': 'v1.*', 'do': 'make install_jsregexp' }
    Plug 'rktjmp/lush.nvim'
    Plug 'echasnovski/mini.move', { 'branch': 'stable' }
    Plug 'folke/neodev.nvim'
    Plug 'shortcuts/no-neck-pain.nvim', { 'tag': '*' }
    Plug 'jose-elias-alvarez/null-ls.nvim'
    Plug 'kevinhwang91/nvim-bqf'
    Plug 'neovim/nvim-lspconfig'
    Plug 'norcalli/nvim-colorizer.lua'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'kylechui/nvim-surround'
    Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
    Plug 'RRethy/nvim-treesitter-endwise'
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'stevearc/oil.nvim'
    Plug 'rgroli/other.nvim'
    Plug 'nvim-treesitter/playground'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'Wansmer/sibling-swap.nvim'
    Plug 'sQVe/sort.nvim'
    Plug 'axelvc/template-string.nvim'
    Plug 'folke/todo-comments.nvim'
    Plug 'Wansmer/treesj'
    Plug 'dmmulroy/ts-error-translator.nvim'
    Plug 'pmizio/typescript-tools.nvim'
    Plug 'MisanthropicBit/vim-yank-window'
    Plug 'MisanthropicBit/winmove.nvim'
    Plug 'lewis6991/gitsigns.nvim'
    Plug 'rafcamlet/tabline-framework.nvim'

    " neotest + adapters
    Plug 'nvim-neotest/neotest'
    Plug 'nvim-neotest/neotest-plenary'
    Plug 'haydenmeade/neotest-jest'
    Plug 'adrigzr/neotest-mocha'
    Plug '~/projects/vim/neotest-busted'

    " nvim-cmp plugin and sources
    Plug 'Gelio/cmp-natdat/'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'hrsh7th/cmp-emoji'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'saadparwaiz1/cmp_luasnip'

    " dap
    Plug 'mfussenegger/nvim-dap'
    Plug 'mxsdev/nvim-dap-vscode-js'
    Plug 'rcarriga/nvim-dap-ui'

    Plug '~/projects/vim/docs.nvim'

    call plug#end()
]])

require("config.plugins.vim-plugins.vim-startify")
