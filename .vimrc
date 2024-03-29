" Author: Alexander Asp Bock
" Source: https://github.com/MisanthropicBit/dotfiles

let mapleader = "\<space>"
let maplocalleader = "\<space>"

let has_nvim = has('nvim')

" Plugins {{{

call plug#begin('~/.vim/plugged')

" Adds help for vim-plug itself
Plug 'junegunn/vim-plug'

Plug 'airblade/vim-gitgutter'
Plug 'andymass/vim-matchup'
Plug 'arthurxavierx/vim-caser'
Plug 'honza/vim-snippets'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'Konfekt/FastFold'
Plug 'mhinz/vim-startify'
Plug 'MisanthropicBit/vim-yank-window'
Plug 'Raimondi/delimitMate'
Plug 'rhysd/git-messenger.vim'
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
Plug 'AndrewRadev/linediff.vim'

" Colorschemes
Plug 'sainnhe/everforest'
Plug 'wadackel/vim-dogrun'
Plug 'savq/melange'
Plug 'hardhackerlabs/theme-vim', { 'as': 'hardhacker' }

if has_nvim
    if executable('node') && executable('yarn')
        Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install', 'for': ['markdown', 'vim-plug'] }
    else
        Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
    endif

    Plug 'neovim/nvim-lspconfig'
    Plug 'rmagatti/goto-preview'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'folke/trouble.nvim'
    Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'nvim-treesitter/playground'
    Plug 'rktjmp/lush.nvim'
    Plug 'nvimdev/lspsaga.nvim', { 'branch': 'main' }
    Plug 'nvim-lua/plenary.nvim'
    Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
    Plug 'nat-418/boole.nvim'
    Plug 'ray-x/lsp_signature.nvim'
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'jose-elias-alvarez/null-ls.nvim'
    Plug 'ckolkey/ts-node-action'
    Plug 'nvimdev/dashboard-nvim'
    Plug 'ibhagwan/fzf-lua', { 'branch': 'main' }
    Plug 'stevearc/oil.nvim'
    Plug 'kevinhwang91/nvim-bqf'
    Plug 'mrjones2014/smart-splits.nvim'
    Plug 'nvim-lualine/lualine.nvim'
    Plug 'Wansmer/treesj'
    Plug 'L3MON4D3/LuaSnip', { 'tag': 'v1.*', 'do': 'make install_jsregexp' }
    Plug 'rafamadriz/friendly-snippets'
    Plug 'folke/todo-comments.nvim'
    Plug 'sindrets/diffview.nvim'

    " neotest + adapters
    Plug 'nvim-neotest/neotest'
    Plug 'haydenmeade/neotest-jest'
    Plug 'nvim-neotest/neotest-plenary'

    " nvim-cmp plugin and sources
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'saadparwaiz1/cmp_luasnip'

    " nvim colorschemes
    Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'EdenEast/nightfox.nvim'
    Plug 'shaunsingh/moonlight.nvim'
    Plug 'kartikp10/noctis.nvim'
    Plug 'w3barsi/barstrata.nvim'
    Plug 'rebelot/kanagawa.nvim'
    Plug 'hoprr/calvera-dark.nvim'
    Plug 'ramojus/mellifluous.nvim'
    Plug 'kvrohit/mellow.nvim'
    Plug 'maxmx03/fluoromachine.nvim'
    Plug 'ribru17/bamboo.nvim'
    Plug 'lmburns/kimbox'
    Plug 'AstroNvim/astrotheme'
    Plug 'AlexvZyl/nordic.nvim'
    Plug 'xero/miasma.nvim'
    Plug 'Shatur/neovim-ayu'
    Plug 'tiagovla/tokyodark.nvim'

    " dap
    Plug 'mfussenegger/nvim-dap'
    Plug 'mxsdev/nvim-dap-vscode-js'
    Plug 'rcarriga/nvim-dap-ui'

    " Local projects
    Plug '~/projects/vim/neotest-fuzzy'
    Plug '~/projects/vim/vim-warlock'

    " NOTE: isdirectory doesn't check if the directory is readable
    if isdirectory(expand('~/projects/vim/decipher.nvim'))
        Plug '~/projects/vim/decipher.nvim'
    else
        Plug 'MisanthropicBit/decipher.nvim'
    endif
else
    Plug 'editorconfig/editorconfig-vim'
    Plug 'ryanoasis/vim-devicons'
endif

call plug#end()

" }}}

" Functions {{{

if !has_nvim
    " Show syntax group, linked group and colors for current word
    function! <SID>SynStack() abort
        if !exists('*synID') || !exists('*synIDtrans') || !exists('*synIDattr')
            return
        endif

        let synID = synID(line('.'), col('.'), 0)

        if synID == 0
            echo 'No syntax information for element'
            return
        endif

        let name = synIDattr(synID, 'name')
        let linkedGroup = synIDtrans(synID)

        if synID != linkedGroup
            " This is not the root of the stack
            let synID = linkedGroup
        endif

        echohl Title | echon 'Name  ' | echohl None | echo name "\n\n"
        echohl Title | echon 'Root  ' | echohl None | execute printf(':hi %s', synIDattr(synID, 'name'))
    endfunction
endif

" Function that deletes trailing whitespace
function! <SID>DeleteTrailingWhitespace()
    " Save current search history and position
    let s = @/
    let line = line('.')
    let col = col('.')

    " '%' specifies the entire file, 'e' supresses error messages
    %s/\s\+$//e

    " Restore previous search history and position
    let @/ = s
    call cursor(line, col)
endfunction

" Move a range of lines up or down while retaining folds
function! s:FoldSafeMove(dir) range
    let dist = (a:dir > 0 ? v:count1 : -1 - v:count1)

    if line('.') + dist > line('$') || line('.') + dist < 0
        return
    endif

    setlocal foldmethod=manual
    let oldfoldmethod = &l:foldmethod
    let oldcol = col('.')

    execute "silent m ." . string(dist) . "<cr>"

    let &l:foldmethod = oldfoldmethod
    call cursor('.', oldcol)
endfunction

" Visually move a range of lines up or down while retaining folds
"
" TODO: Test if we can use getpos("'<") to do correct target calculations
function! s:FoldSafeVisualMove(dir) range
    if a:dir > 0
        let target = a:lastline + v:count1
    else
        let target = a:firstline - v:count1 - 1
    endif

    if target > line('$') || target < 0
        normal! gv
        return
    endif

    setlocal foldmethod=manual
    let oldfoldmethod = &l:foldmethod

    execute printf("silent %s,%sm %s<cr>", a:firstline, a:lastline, target)

    let &l:foldmethod = oldfoldmethod
    normal! gv
endfunction

" Reselect a visual selection after indenting or dedenting
function! s:VisualIndentReselect(dir)
    execute (a:dir >= 1 ? '>' : '<')
    normal! gv
endfunction

" }}}

" General {{{

set nocompatible
set number
set laststatus=2
set wildmenu
set cursorline

filetype plugin on

if v:version >= 703
    set relativenumber
endif

" Set margin for the zt and zb commands
set scrolloff=3

" Display current line and column in the bottom-right corner
set ruler

" Unrestricted use of the backspace key in insert mode
set backspace=indent,eol,start

" Allow yank and put between vim sessions without specifying
" the clipboard ("*) register
set clipboard+=unnamed

set wildignore+=.hg,.git,.svn                                 " Version control files
set wildignore+=*.aux,*.bbl,*.bcf,*.blg,*.run.xml,*.toc,*.xdv " LaTeX files
set wildignore+=*.acn,*.glo,*.ist,*.pag,*.synctex.gz          " More LaTeX files
set wildignore+=*.jpeg,*.jpg,*.bmp,*.gif,*.png,*.tiff         " Image files
set wildignore+=*.o,*.obj,*.exe,*.dll,*.*.manifest            " Object files
set wildignore+=*.sw?                                         " vim swap files
set wildignore+=*.pyc                                         " Python bytecode files
set wildignore+=*.class                                       " Java class files
set wildignore+=*.fdb_latexmk,*.fls                           " Latexmk build files

" List log files at the end
set suffixes+=*.log

" Trying out some of Steve Losh's vimrc stuff
set visualbell
set showbreak="↪ "
set shiftround
set linebreak
set formatoptions=croqlnt
set ignorecase
set smartcase

" Very magic modifier does not work in vscode
if !exists('g:vscode')
    nnoremap / /\v
    vnoremap / /\v
endif

" Highlight select languages in markdown code blocks
let g:markdown_fenced_languages = [
    \'html',
    \'python',
    \'bash=sh',
    \'vim',
    \'lua',
    \'mysql',
    \'sql'
\]

set signcolumn=yes:2
set updatetime=500
set noswapfile
set keywordprg=:DocsCursor

" }}}

" Colors and syntax {{{

" Attempt to use true-colors in terminal vim, otherwise fall back to 256 colors
if !has('gui_running')
    if has('termguicolors') || has_nvim
        set termguicolors

        " Setting these two ANSI color escape sequences is sometimes necessary
        " See ':help xterm-true-color' and https://github.com/vim/vim/issues/993
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    else
        set t_Co=256
    endif
endif

" Enable syntax highlighting
syntax on

" Default to using bash syntax highlighting
let g:is_bash = 1

" Highlight git merge conflict markers
match ErrorMsg '\v^(\<|\=|\>){7}([^\=].+)?$'

" }}}

" Indentation {{{

" Get rid of default preprocessor directive indentation rules which removes
" all indentation
set cinkeys-=0#

" }}}

" Mappings {{{

if !has_nvim
    " Display the syntax group(s) of the current word
    nnoremap <silent> <localleader>sg :call <SID>SynStack()<cr>
endif

nnoremap <silent> <localleader><space> :nohl<cr>
nnoremap <localleader>w :w<cr>
nnoremap <localleader>q :q<cr>
nnoremap <localleader>Q :qa!<cr>
nnoremap <localleader>vs :sp $MYVIMRC<cr>
nnoremap <localleader>vv :vsp $MYVIMRC<cr>
nnoremap <localleader>vt :tabe $MYVIMRC<cr>
nnoremap <localleader>sv :source $MYVIMRC<cr>
inoremap <expr> jk "<esc>"
nnoremap <c-o> <c-o>zz
nnoremap <c-i> <c-i>zz
inoremap <expr> TODOT printf('TODO (%s): ', strftime('%Y-%m-%d, %H:%M:%S'))
nnoremap <silent> Q @@

" Shortcut for correcting a misspelled word with its first suggestion
nnoremap <localleader>1 1z=

" Move vertically while ignoring true lines
nnoremap j gj
nnoremap k gk

" Easily swap the current line up and down
" Based on: https://github.com/vim/vim/issues/536
nnoremap <silent> J :call <SID>FoldSafeMove(1)<cr>
nnoremap <silent> K :call <SID>FoldSafeMove(-1)<cr>
vnoremap <silent> J :call <SID>FoldSafeVisualMove(1)<cr>
vnoremap <silent> K :call <SID>FoldSafeVisualMove(-1)<cr>

" Open the 'goto file' in a new tab
nnoremap gf <c-w>gf

if !has_nvim
    nnoremap Y y$
end

" Quickly toggle folds
nnoremap <localleader>fl za

" Delete trailing whitespace (should this be an autocommand on saving/exiting?)
nnoremap <silent> <localleader>rw :call <SID>DeleteTrailingWhitespace()<cr>

" Open manpage (default) for the word under the cursor (since K is remapped to
" moving lines upwards)
nnoremap <silent> <localleader>k K

" Automatically reselect the visual block when indenting or dedenting
vnoremap <silent> > :call <SID>VisualIndentReselect(1)<cr>
vnoremap <silent> < :call <SID>VisualIndentReselect(-1)<cr>

" Disable arrow keys and page-up/down in normal-, insert- and visual-mode
"
" For a plugin solution, see https://github.com/wikitopian/hardmode
nnoremap <Up>       <nop>
nnoremap <Down>     <nop>
nnoremap <Left>     <nop>
nnoremap <Right>    <nop>
nnoremap <PageUp>   <nop>
nnoremap <PageDown> <nop>
inoremap <Up>       <nop>
inoremap <Down>     <nop>
inoremap <Left>     <nop>
inoremap <Right>    <nop>
inoremap <PageUp>   <nop>
inoremap <PageDown> <nop>
vnoremap <Up>       <nop>
vnoremap <Down>     <nop>
vnoremap <Left>     <nop>
vnoremap <Right>    <nop>
vnoremap <PageUp>   <nop>
vnoremap <PageDown> <nop>

" Use familiar cmdline binding in vim's cmdline
cnoremap <c-a> <c-b>
cnoremap <m-left> <c-left>
cnoremap <m-right> <c-right>
cnoremap <c-h> <c-left>
cnoremap <c-l> <c-right>

" Prefill different branches on the command line for fugitive commands
cnoremap <c-o> origin/master:
cnoremap <c-b> <c-r>=printf('origin/%s', FugitiveHead())<cr>
cnoremap <c-d> <c-r>=expand('%:p:h') . '/'<cr>

let s:conflict_marker_regex = '^\(\(\(<<<<<<<\)\|\(|||||||\)\|\(>>>>>>>\)\) .\+\|\(=======\)\)'

function s:FindGitConflictMarker(dir) abort
    call search(s:conflict_marker_regex, a:dir ==# 1 ? 'w' : 'bw')
endfunction

nnoremap <silent> >m <cmd>call <SID>FindGitConflictMarker(1)<cr>
nnoremap <silent> <m <cmd>call <SID>FindGitConflictMarker(-1)<cr>

nnoremap <silent> <localleader>ct :let @+ = expand('%:t')<cr>
nnoremap <silent> <localleader>ch :let @+ = expand('%:h')<cr>
nnoremap <silent> <localleader>cp :let @+ = expand('%:p')<cr>

" }}}

" Searching {{{

" Highlight searches
set hlsearch

" Use incremental search
set incsearch

" Do not jump forward to the next match when searching for the current word
nnoremap <silent> * *Nzz

" Center the next or previous search matches
nnoremap n nzvzz
nnoremap N Nzvzz

if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
    set grepformat=%f:%l:%c:%m
endif

" }}}

" Tabs, spaces and indentation {{{

set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent

" }}}

" Tabs (the buffer ones) {{{

nnoremap <c-t><c-o> :tabonly<cr>
nnoremap L gt
nnoremap H gT

" Tab navigation inspired by vimium
nnoremap g0 :tabnext 1<cr>
nnoremap g$ :tabnext $<cr>

" Open up to 15 tabs, instead of 10, with the '-p' option
set tabpagemax=15

" Always show tabs
set showtabline=2

if !exists('g:last_tab')
    let g:last_tab = tabpagenr()
endif

nnoremap <localleader>pt :execute 'tabnext ' . g:last_tab<cr>

augroup LastTab
    autocmd!
    autocmd TabLeave * let g:last_tab = tabpagenr()
augroup END

" }}}

" Windows {{{

nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
set splitright

" }}}

" Folding {{{

" Only close folds that are at level 3 or higher
set foldlevel=3

" Using indentation to determine folding
set foldmethod=indent

" Maximum nesting for folds is 3
set foldnestmax=3

" }}}

" Commands {{{

command! -nargs=+ Grep execute 'silent grep! <args> | copen'

" }}}

" Autocommands {{{

if has('autocmd')
    augroup vimresize
        " Automatically resize windows when vim is resized
        autocmd!
        autocmd VimResized * tabdo :wincmd =
    augroup END

    augroup trailing
        " Show trailing whitespace when not in insert mode
        autocmd!
        autocmd InsertEnter * set listchars-=trail:⌴,nbsp:¬
        autocmd InsertLeave * set listchars+=trail:⌴,nbsp:¬
    augroup END

    augroup save_edit_position
        " Remember last editing position (see ':h last-position-jump')
        " Use 'zv' to open just enough folds for the line to be visible and
        " 'zz' to center the line
        autocmd!
        autocmd BufReadPost *
            \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'gitcommit' |
            \   execute 'normal! g`"zvzz' |
            \ endif
    augroup END

    augroup fsproj
        autocmd!
        autocmd BufRead,BufNewFile *.fsproj setlocal ft=xml
    augroup END

    augroup web
        autocmd!
        autocmd BufRead,BufNewFile *.html,*.yml,*.json setlocal shiftwidth=2
    augroup END

    augroup docker
        " Use dockerfile syntax for production, test dockerfiles etc.
        autocmd!
        autocmd BufRead,BufNewFile Dockerfile.* setlocal filetype=dockerfile
    augroup END

    augroup jslintrc
        autocmd!
        autocmd BufRead,BufNewFile .eslintrc setlocal filetype=json
    augroup END

    augroup terminal
        autocmd!
        autocmd TermOpen set signcolumn=no
    augroup END

    augroup gitconfig
        autocmd!
        autocmd BufRead,BufNewFile .*gitconfig setlocal filetype=gitconfig
    augroup END
endif

" }}}

" Databases {{{

let g:sql_type_default = 'mysql'

" }}}

" Shell {{{

set shell=fish

" }}}

" Terminal {{{

if exists(':tnoremap') == 2
    tnoremap jk <c-\><c-n>
endif

nnoremap <silent> <c-t><c-s> :Term<cr>
nnoremap <silent> <c-t><c-v> :vert Term<cr>
nnoremap <silent> <c-t><c-t> :tab Term<cr>

" }}}

" Explorer {{{

let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

" }}}

" Plugin configuration {{{

" delimitMate {{{

" Expand any pair of delimiting characters when pressing enter
let delimitMate_expand_cr = 1

" }}}

" fzf {{{

" Add fzf paths for both homebrew and macports
set rtp+=/opt/local/share/fzf/vim
set rtp+=/usr/local/opt/fzf

" ctrl-s makes more sense to me for split windows
let g:fzf_action = {
    \'ctrl-t': 'tab split',
    \'ctrl-s': 'split',
    \'ctrl-v': 'vsplit',
\}

command! -bang -nargs=* -complete=dir Dirs
\ call fzf#run(fzf#wrap({'source': 'fd --type d --color=never', 'options': ['--preview', 'tree -C -L 1 {}']}))

nnoremap <silent> <localleader>gf :GFiles<cr>
nnoremap <silent> <localleader>hi :His<cr>
nnoremap <silent> <localleader>rg :Rg<cr>

" }}}

" vim-gitgutter {{{

nmap <silent> gj <Plug>(GitGutterNextHunk)zz
nmap <silent> gk <Plug>(GitGutterPrevHunk)zz
nmap <silent> <localleader>hv <Plug>(GitGutterPreviewHunk)
nmap <silent> <localleader>hs <Plug>(GitGutterStageHunk)

let g:gitgutter_floating_window_options = {
    \'relative': 'cursor',
    \'row': 1,
    \'col': 0,
    \'width': 42,
    \'height': &previewheight,
    \'style': 'minimal',
    \'border': 'rounded'
\}
let g:gitgutter_set_sign_backgrounds = 1
let g:gitgutter_sign_added = '┃'
let g:gitgutter_sign_modified = '┃'
let g:gitgutter_sign_removed = '┃'
let g:gitgutter_sign_modified_removed = '║'

" }}}

" git-messenger.vim {{{

let g:git_messenger_conceal_word_diff_marker = 1

" }}}

" linediff.vim {{{

nnoremap <localleader>dv :Linediff
xmap <silent> gl <Plug>(linediff-operator) 
nmap <silent> gl <Plug>(linediff-operator) 

" }}}

" vim-devicons {{{

if !has_nvim
    let g:DevIconsEnableFoldersOpenClose = 1
    " let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {}
    " let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['mysql'] = g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['sql']
endif

" }}}

" vim-easy-align {{{

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" }}}

" vim-fugitive {{{

" Useful git mappings based on the spf13-vim distribution
nnoremap <silent> <localleader>gs :G<cr>
nnoremap <silent> <localleader>gd :Gdiffsplit<cr>
nnoremap <silent> <localleader>gc :G commit<cr>
nnoremap <silent> <localleader>gb :G blame<cr>
nnoremap <silent> <localleader>gl :Term git log<cr>
nnoremap <silent> <localleader>gp :G push<cr>
nnoremap <silent> <localleader>gv :vert G --paginate diff --cached<cr>
nnoremap <silent> <localleader>gw :Gwrite<cr>
nnoremap <silent> <localleader>gu :GBrowse!<cr>
xnoremap <silent> <localleader>gu :GBrowse!<cr>
nnoremap <silent> <localleader>gos :Gsp origin/master:%<cr>
nnoremap <silent> <localleader>gov :Gvs origin/master:%<cr>
nnoremap <silent> <localleader>got :Gtabedit origin/master:%<cr>

" Define a command and mapping for viewing staged changes
command! Gcached :Gtabedit! diff --cached
command! Gom :<mods> Gsp origin/master:%
nnoremap <silent> <localleader>gr :Gcached<cr>

" }}}

" vim-startify {{{

let g:startify_custom_header_quotes = [
    \['The optimal allocation is one that never happens.', '', '- Joseph E. Hoag'],
    \['Design is, as always, the art of finding compromises.', '', '- Eric Lippert'],
    \['Abstract interpretation allows us to ask the question: "What information can we glean from our program before we run it, possibly sharing the answers with an interpreter or a compiler?"', '', '- Friedman and Mendhekar'],
    \['The goal of abstract interpretation is to allow the user to do program analysis with a set of values that abstract another set of values.', '', '- Friedman and Mendhekar']
\] + startify#fortune#predefined_quotes()

if has_nvim
    let g:startify_disable_at_vimenter = 1
endif

" }}}

" vim-surround {{{

" Quickly surround text with LaTeX (e)nvironments
"
" For example, typing 'ySwe' followed by 'center' when prompted on the text '|hello'
" where '|' is the cursor yields:
"
" \begin{center}
"     hello
" \end{center}
let g:surround_{char2nr('e')}="\\begin{\1environment: \1}\r\\end{\1\1}"

" Quickly surround text with LaTeX markup
"
" For example, typing 'ySwl' followed by 'textbf' when prompted on the text '|vim'
" where '|' is the cursor yields:
"
" \textbf{vim}
"let g:surround_{char2nr('l')}="\\\1markup: \1{\r}"

" Surround text with a LaTeX command using 'c'
let g:surround_{char2nr('c')} = "\\\1command\1{\r}"

" }}}

" vim-yank-window {{{

let g:yank_window#enable_mappings = 1

" }}}

" }}}

" neovim/lua config {{{

if has_nvim
    " Enable interactive command line substitution without window splitting
    set inccommand=nosplit

    let s:python3_host_prog_base_path = '~/.neovim_venvs/neovim3'

    " Point neovim to its specific python virtual environments
    let g:python_host_prog = expand('~/.neovim_venvs/neovim2/bin/python')
    let g:python3_host_prog = expand(s:python3_host_prog_base_path . '/bin/python')

    " vim supports a 'vertical'/'tab' prefix before :terminal, but neovim
    " currently doesn't
    command! -nargs=* Term <mods> new | startinsert | term <args>

    lua require('config')
endif

" }}}

" vim: foldenable foldmethod=marker foldlevel=0 fileencoding=utf-8
