require("config.plugins.vim-plugins.delimiteMate")
require("config.plugins.vim-plugins.git-messenger")
require("config.plugins.vim-plugins.gitgutter")
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
    Plug 'Shatur/neovim-ayu'
    Plug 'askfiy/visual_studio_code'
    Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'hoprr/calvera-dark.nvim'
    Plug 'kvrohit/mellow.nvim'
    Plug 'lmburns/kimbox'
    Plug 'maxmx03/fluoromachine.nvim'
    Plug 'projekt0n/caret.nvim'
    Plug 'ramojus/mellifluous.nvim'
    Plug 'rebelot/kanagawa.nvim'
    Plug 'ribru17/bamboo.nvim'
    Plug 'sainnhe/everforest'
    Plug 'savq/melange'
    Plug 'shaunsingh/moonlight.nvim'
    Plug 'tiagovla/tokyodark.nvim'
    Plug 'LunarVim/horizon.nvim'

    if executable('node') && executable('yarn')
        Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install', 'for': ['markdown', 'vim-plug'] }
    else
        Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }
    endif

    Plug 'AndrewRadev/linediff.vim'
    Plug 'Konfekt/FastFold'
    Plug 'Raimondi/delimitMate'
    Plug 'airblade/vim-gitgutter'
    Plug 'andymass/vim-matchup'
    Plug 'arthurxavierx/vim-caser'
    Plug 'honza/vim-snippets'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
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

    Plug 'L3MON4D3/LuaSnip', { 'tag': 'v1.*', 'do': 'make install_jsregexp' }
    Plug 'MisanthropicBit/decipher.nvim'
    Plug 'MisanthropicBit/vim-yank-window'
    Plug 'MisanthropicBit/winmove.nvim'
    Plug 'Wansmer/sibling-swap.nvim'
    Plug 'Wansmer/treesj'
    Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
    Plug 'axelvc/template-string.nvim'
    Plug 'ckolkey/ts-node-action'
    Plug 'echasnovski/mini.move', { 'branch': 'stable' }
    Plug 'folke/neodev.nvim'
    Plug 'folke/todo-comments.nvim'
    Plug 'folke/trouble.nvim'
    Plug 'ibhagwan/fzf-lua', { 'branch': 'main' }
    Plug 'jose-elias-alvarez/null-ls.nvim'
    Plug 'kevinhwang91/nvim-bqf'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'kylechui/nvim-surround'
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'nat-418/boole.nvim'
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'nvim-treesitter/playground'
    Plug 'nvimdev/dashboard-nvim'
    Plug 'rafamadriz/friendly-snippets'
    Plug 'ray-x/lsp_signature.nvim'
    Plug 'rgroli/other.nvim'
    Plug 'rktjmp/lush.nvim'
    Plug 'rmagatti/goto-preview'
    Plug 'sindrets/diffview.nvim'
    Plug 'stefanlogue/hydrate.nvim'
    Plug 'stevearc/oil.nvim'

    " neotest + adapters
    Plug 'nvim-neotest/neotest'
    Plug 'nvim-neotest/neotest-plenary'
    Plug 'haydenmeade/neotest-jest'

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

    call plug#end()
]])

require("config.plugins.vim-plugins.vim-startify")
