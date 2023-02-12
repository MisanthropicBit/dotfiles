" Author: Alexander Asp Bock
" Source: https://github.com/MisanthropicBit/dotfiles

" Set leader character
let mapleader = "\<space>"

" Set the local leader character
let maplocalleader = "\<space>"

" Plugins {{{

call plug#begin('~/.vim/plugged')

" Adds help for vim-plug itself
Plug 'junegunn/vim-plug'

Plug 'airblade/vim-gitgutter'
Plug 'AndrewRadev/sideways.vim'
Plug 'andymass/vim-matchup'
Plug 'arthurxavierx/vim-caser'
Plug 'dag/vim-fish'
" Plug 'dense-analysis/ale'
Plug 'editorconfig/editorconfig-vim'
Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/vim-easy-align'
Plug 'Konfekt/FastFold'
Plug 'mhinz/vim-startify'
" Plug 'bfrg/vim-cpp-modern'
Plug 'MisanthropicBit/vim-numbers'
Plug 'MisanthropicBit/vim-yank-window'
Plug 'MisanthropicBit/decipher.nvim'
Plug 'pangloss/vim-javascript'
Plug 'Raimondi/delimitMate'
Plug 'rhysd/git-messenger.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree'
Plug 'sirver/UltiSnips'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-surround'
" Plug 'vim-test/vim-test'

" Colorschemes
Plug 'ajmwagar/vim-deus'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'embark-theme/vim'
Plug 'haishanh/night-owl.vim'
Plug 'rhysd/vim-color-spring-night'
Plug 'sainnhe/everforest'
Plug 'wadackel/vim-dogrun'
Plug 'mhartington/oceanic-next'
Plug 'savq/melange'
Plug 'ackyshake/Spacegray.vim'

if has('nvim')
    if executable('node') && executable('yarn')
        Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
    else
        Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
    endif

    Plug 'neovim/nvim-lspconfig'
    Plug 'rmagatti/goto-preview'
    Plug 'kyazdani42/nvim-web-devicons'
    Plug 'folke/trouble.nvim'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    Plug 'nvim-treesitter/playground'
    Plug 'rktjmp/lush.nvim'
    Plug 'glepnir/lspsaga.nvim', { 'branch': 'main' }
    Plug 'nvim-lua/plenary.nvim'
    Plug 'akinsho/bufferline.nvim', { 'tag': 'v2.*' }
    Plug 'sbdchd/neoformat'
    Plug 'nat-418/boole.nvim'
    Plug 'ray-x/lsp_signature.nvim'
    Plug 'lukas-reineke/indent-blankline.nvim'
    Plug 'jose-elias-alvarez/null-ls.nvim'
    Plug 'ckolkey/ts-node-action'
    Plug 'glepnir/dashboard-nvim'
    Plug 'ibhagwan/fzf-lua', {'branch': 'main'}

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
    Plug 'quangnguyen30192/cmp-nvim-ultisnips'

    " nvim colorschemes
    Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
    Plug 'folke/tokyonight.nvim', { 'branch': 'main' }
    Plug 'EdenEast/nightfox.nvim'
    Plug 'shaunsingh/moonlight.nvim'
    Plug 'navarasu/onedark.nvim'
    Plug 'glepnir/zephyr-nvim'
    Plug 'kartikp10/noctis.nvim'
    Plug 'w3barsi/barstrata.nvim'
    Plug 'projekt0n/github-nvim-theme'
    Plug 'rebelot/kanagawa.nvim'

    " dap
    Plug 'mfussenegger/nvim-dap'
    Plug 'mxsdev/nvim-dap-vscode-js'
    Plug 'rcarriga/nvim-dap-ui'

    " Local projects
    Plug '~/projects/vim/decipher.nvim'
    Plug '~/projects/vim/neotest-fuzzy'
endif

" Local plugins and active forks
Plug '~/projects/vim/vim-warlock'

runtime private.vim

call plug#end()

" }}}

" Functions {{{

if !has('nvim')
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

function! s:OpenScratchBuffer(text, height, location, leave_map) abort
    let loc = a:location

    if a:location == 'auto'
        let loc = 'bel'
    endif

    " Open the new window
    execute printf('%s %dnew', loc, a:height)

    if len(a:leave_map)
        " Useful mapping for leaving the scratch-buffer
        execute printf('nnoremap <buffer> <silent> %s :q<cr>', a:leave_map)
    endif

    " Set text of the buffer
    call setline(1, split(a:text, '\n'))

    " Make this a scratch-buffer
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal readonly
endfunction

" Automatically close the NERDTree file explorer window
" if it is the only window left
" Credit: https://github.com/scrooloose/nerdtree/issues/21
function! s:CloseNerdTreeIfOnlyWindow()
    if exists('t:NERDTreeBufName')
        if bufwinnr(t:NERDTreeBufName) != -1
            if winnr('$') == 1
                q
            endif
        endif
    endif
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

let s:builtin_colorschemes = [
    \'blue',
    \'darkblue',
    \'default',
    \'delek',
    \'desert',
    \'elflord',
    \'evening',
    \'industry',
    \'koehler',
    \'morning',
    \'murphy',
    \'pablo',
    \'peachpuff',
    \'ron',
    \'shine',
    \'slate',
    \'torte',
    \'zellner',
\]

" For use in s:RandomColorscheme. Lists colorschemes that are broken or do not
" support true-color
let s:exclude_colorschemes = []

" Find and choose and random user-defined colorscheme
function! s:RandomColorscheme(bang)
    let user_colorschemes = s:GetPluginColorschemes(!a:bang)

    if &shell =~# 'bash'
        let random = system('echo -n $RANDOM')
    elseif &shell =~# 'fish'
        let random = system('echo -n (random)')
    else
        let random = 0
    endif

    let irandom = str2nr(random)
    let chosen = get(user_colorschemes, irandom % len(user_colorschemes))

    execute ':colorscheme ' . chosen

    return chosen
endfunction

" Return a list of colorschemes installed by plugin, excluding built-in
" colorschemes
function! s:GetPluginColorschemes(use_preferred, ...) abort
    let user_colorschemes = []

    if a:use_preferred && exists('s:preferred_colors')
        let user_colorschemes = s:preferred_colors
    else
        let colors = map(split(globpath(&runtimepath, 'colors/*.vim'), '\n'),
                        \'fnamemodify(v:val, ":t:r")')

        if has('packages')
            let colors += split(globpath(&packpath, 'pack/*/opt/*/colors/*.vim'), '\n')
        endif

        let exclude = []

        if exists('s:builtin_colorschemes')
            let exclude += s:builtin_colorschemes
        endif

        if a:0 > 0 && !empty(a:1)
            let exclude += a:1
        endif

        let user_colorschemes = filter(colors, 'index(exclude, v:val) == -1')
    endif

    return uniq(sort(user_colorschemes))
endfunction

" Find the root directory of the current project
function s:LocateProjectRoot(depth, ...) abort
    let gitdir = system('git rev-parse --show-toplevel')

    if gitdir !~# '^fatal:'
      return gitdir
    endif

    let root_dir_markers = ['.git', '.hg', '.svn', '.bzr']
    let root_file_markers = ['.gitignore', 'MANIFEST.in', 'tox.ini', 'setup.py']
    let depth = a:depth
    let cwd = getcwd()

    if a:0 > 0
        let root_dir_markers += a:1
    endif

    if a:0 > 1
        let root_file_markers += a:2
    endif

    while depth > 0
        for dir in root_dir_markers
            if !empty(finddir(dir, cwd))
                return cwd
            endif
        endfor

        for filename in root_file_markers
            if !empty(findfile(filename, cwd))
                return cwd
            endif
        endfor

        let cwd = fnamemodify(cwd, ':h')
        let depth -= 1
    endwhile

    return ''
endfunction

" }}}

" General {{{

" Ignore backwards compatibility to vi
set nocompatible

" Always display current mode
set showmode

" Show line numbers
set number

" Start out in combined number and relativenumber mode if possible
if v:version >= 703
    set relativenumber
endif

" Prefer utf-8
set encoding=utf8

" Set margin for the zt and zb commands
set scrolloff=3

" Allow mouse clicks to change cursor position
if has('mouse')
    set mouse=a
endif

" No sounds on errors
set noerrorbells

" Display current line and column in the bottom-right corner
set ruler

" Always show vim-airline
set laststatus=2

" Unrestricted use of the backspace key in insert mode
set backspace=indent,eol,start

" Use the filetype plugin
filetype plugin on

" Allow yank and put between vim sessions without specifying
" the clipboard ("*) register
set clipboard+=unnamed

" Make sure gvim and mvim use a powerline font
if has('gui_running')
    set guifont=Monaco\ For\ Powerline
endif

" Prefer wildmenu
set wildmenu

" Set file patterns to ignore in the wildmenu
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
nnoremap / /\v
vnoremap / /\v

" Highlight the line which the cursor is on
set cursorline

" Highlight select languages in markdown code blocks
let g:markdown_fenced_languages = [
    \'html',
    \'python',
    \'bash=sh',
    \'vim',
\]

set signcolumn=yes:2

set updatetime=500

" }}}

" Colors and syntax {{{

" Attempt to use true-colors in terminal vim, otherwise fall back to 256 colors
if !has('gui_running')
    if has('termguicolors') || has('nvim')
        set termguicolors

        " Setting these two ANSI color escape sequences is sometimes necessary
        " See ':help xterm-true-color' and https://github.com/vim/vim/issues/993
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    else
        set t_Co=256
    endif
endif

" Disable until treesitter hl groups are fixed
" \'aurora',
let s:preferred_colors = [
    \'barstrata',
    \'catppuccin',
    \'dogrun',
    \'duskfox',
    \'embark',
    \'everforest',
    \'kanagawa',
    \'melange',
    \'moonlight',
    \'night-owl',
    \'nightfox',
    \'nordfox',
    \'OceanicNext',
    \'spring-night',
    \'spacegray',
    \'terafox',
    \'tokyonight-night',
    \'tokyonight-storm',
    \'warlock',
    \'zephyr',
\]

let g:default_colorscheme_override = ''

" Set the default colorscheme
try
    if exists('g:default_colorscheme_override') && !empty(g:default_colorscheme_override)
        execute printf('colorscheme %s', g:default_colorscheme_override)
    else
        call s:RandomColorscheme(0)
    endif
catch
    try
        colorscheme duskfox
    catch
        colorscheme default
    endtry
endtry

" Enable syntax highlighting
syntax on

" Default to using bash syntax highlighting
let g:is_bash = 1

" Highlight git merge conflict markers
match ErrorMsg '\v^(\<|\=|\>){7}([^\=].+)?$'

if has('autocmd')
    augroup Seoul256TerminalColors
        autocmd!
        autocmd ColorScheme seoul256 let g:terminal_color_0 = '#4e4e4e'
            \| let g:terminal_color_1 = '#d68787'
            \| let g:terminal_color_2 = '#5f865f'
            \| let g:terminal_color_3 = '#d8af5f'
            \| let g:terminal_color_4 = '#85add4'
            \| let g:terminal_color_5 = '#d7afaf'
            \| let g:terminal_color_6 = '#87afaf'
            \| let g:terminal_color_7 = '#d0d0d0'
            \| let g:terminal_color_8 = '#626262'
            \| let g:terminal_color_9 = '#d75f87'
            \| let g:terminal_color_10 = '#87af87'
            \| let g:terminal_color_11 = '#ffd787'
            \| let g:terminal_color_12 = '#add4fb'
            \| let g:terminal_color_13 = '#ffafaf'
            \| let g:terminal_color_14 = '#87d7d7'
            \| let g:terminal_color_15 = '#e4e4e4'
    augroup END
endif

" }}}

" Indentation {{{

" Get rid of default preprocessor directive indentation rules which removes
" all indentation
set cinkeys-=0#

" }}}

" Mappings {{{

" Display the syntax group(s) of the current word
nnoremap <silent> <localleader>sg :call <SID>SynStack()<cr>

" Shortcut for disabling highlighting
nnoremap <silent> <localleader><space> :nohl<cr>

" Quickly toggle paste mode
nnoremap <silent> <localleader>pp :setlocal paste!<cr>

" Quickly save the current buffer
nnoremap <leader>w :w<cr>

" Quickly close the current buffer
nnoremap <leader>q :q<cr>

" Shortcut for correcting a misspelled word with its first suggestion
nnoremap <leader>1 1z=

" Move vertically while ignoring true lines
nnoremap j gj
nnoremap k gk

" Shortcut for editing the vimrc file
nnoremap <leader>vs :sp $MYVIMRC<cr>
nnoremap <leader>vv :vsp $MYVIMRC<cr>
nnoremap <leader>vt :tabe $MYVIMRC<cr>

" Shortcut to reload the vimrc file
nnoremap <leader>sv :source $MYVIMRC<cr>

" Easily swap the current line up and down
" Based on: https://github.com/vim/vim/issues/536
nnoremap <silent> J :call <SID>FoldSafeMove(1)<cr>
nnoremap <silent> K :call <SID>FoldSafeMove(-1)<cr>
vnoremap <silent> J :call <SID>FoldSafeVisualMove(1)<cr>
vnoremap <silent> K :call <SID>FoldSafeVisualMove(-1)<cr>

" Open the 'goto file' in a new tab
nnoremap gf <c-w>gf

if !has('nvim')
    " Yank from cursor to the end of line instead of the entire line
    nnoremap Y y$
end

" Quickly toggle folds
nnoremap <leader>f za

" Quickly toggle relative line numbering
if v:version >= 703
    nnoremap <silent> <leader>n :set relativenumber!<cr>
endif

" Quicker way to exit insert mode
inoremap <expr> jk "<esc>"

" Delete trailing whitespace (should this be an autocommand on saving/exiting?)
nnoremap <silent> <leader>rw :call <SID>DeleteTrailingWhitespace()<cr>

" Open manpage (default) for the word under the cursor (since K is remapped to
" moving lines upwards)
nnoremap <silent> <leader>k K

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

" Always center jumps
nnoremap <c-o> <c-o>zz
nnoremap <c-i> <c-i>zz

" Quickly look up a word in the dictionary
if has('mac') || has('macunix')
    nnoremap <silent> <leader>dd :Dict!<cr>
    nnoremap <silent> <leader>DD :Dict<cr>
endif

" Use familiar cmdline binding in vim's cmdline
cnoremap <c-a> <c-b>
cnoremap <m-left> <c-left>
cnoremap <m-right> <c-right>
cnoremap <c-h> <c-left>
cnoremap <c-l> <c-right>

" Tag TODOs with a timestamp
inoremap <expr> TODOT printf('TODO (%s): ', strftime('%Y-%m-%d, %H:%M:%S'))

nnoremap <silent> <localleader>hi :His<cr>

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

command! -nargs=+ Grep execute 'silent grep! <args> | copen'

" }}}

" Tabs, spaces and indentation {{{

" Always use spaces instead of tabs
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" Always use autoindenting
set autoindent

" }}}

" Tabs (the buffer ones) {{{

nnoremap <C-t> :tabnew<cr>

" Faster tab switching using a meta-key
nnoremap <s-l> gt
nnoremap <s-h> gT

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

" Shortcuts for vim window navigation
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" Open vsplits on the right side
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
command! -bang RandomColorscheme :echo printf("Selected: %s", <SID>RandomColorscheme(<bang>0))
" }}}

" Autocommands {{{

if has('autocmd')
    " Automatically resize windows when vim is resized
    augroup vimresize
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

    augroup csharp
        autocmd!
        autocmd FileType cs setlocal indentkeys-=0#
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
endif

" }}}

" Databases {{{
let g:sql_type_default = 'mysql'
" }}}

" Shell {{{
" Allow external bash commands inside vim to use aliases etc.
set shell=fish
" }}}

" Terminal {{{
if exists(':tnoremap') == 2
    " Use escape or 'jk' to exit terminal mode
    tnoremap <esc> <c-\><c-n>
    tnoremap jk <c-\><c-n>
endif

nnoremap <silent> <c-t><c-s> :Term<cr>
nnoremap <silent> <c-t><c-v> :vert Term<cr>
nnoremap <silent> <c-t><c-t> :tab Term<cr>
" }}}

" Explorer {{{
" Show stats in :Explorer mode
let g:netrw_liststyle = 3
" }}}

" Plugin configuration {{{

" ALE {{{
let g:ale_hover_to_floating_preview = 1
let g:ale_floating_window_border = ['│', '─', '╭', '╮', '╯', '╰']
let g:ale_set_signs = 0
let g:ale_sign_error = '✖ '
let g:ale_sign_warning = '!'
let g:ale_sign_style_error = '⚡ '
let g:ale_sign_style_warning = '⛔  '
let g:ale_sign_info = '💡  '
let g:airline#extensions#ale#enabled = 0
let g:ale_echo_msg_format = '[%linter%] %s (%code%:%severity%)'
let g:ale_virtualtext_cursor = 0

if has('nvim')
    " Point to neovim python3 virtual environment for specific language servers
    " let g:ale_python_jedils_executable = expand(s:python3_host_prog_base_path . '/bin/jedi-language-server')
    " let g:ale_vim_vint_executable = expand(s:python3_host_prog_base_path . '/bin/vint')
endif

let s:ale_js_ts_linters = ['prettier']
let s:ale_js_ts_fixers = ['prettier', 'eslint']

" Prefer using local .prettierrc configs. Required for prettier < v1.4.0
let g:ale_javascript_prettier_use_local_config = 1

let g:ale_linters = {
    \'python': ['flake8', 'mypy', 'pylint', 'pyright', 'jedils'],
\}

" let g:ale_linters = {
"     \'javascript': s:ale_js_ts_linters,
"     \'javascriptreact': s:ale_js_ts_linters,
"     \'typescript': s:ale_js_ts_linters,
"     \'typescriptreact': s:ale_js_ts_linters,
" \}

let g:ale_fixers = {
    \'*': ['remove_trailing_lines', 'trim_whitespace'],
    \'python': ['isort'],
    \'javascript': s:ale_js_ts_fixers,
    \'javascriptreact': s:ale_js_ts_fixers,
    \'typescript': s:ale_js_ts_fixers,
    \'typescriptreact': s:ale_js_ts_fixers,
\}

set omnifunc=ale#completion#OmniFunc

nmap <silent> <leader>an <Plug>(ale_next_wrap)
nmap <silent> <leader>ap <Plug>(ale_previous_wrap)
nmap <silent> <leader>af <Plug>(ale_fix)
nmap <silent> <leader>at <Plug>(ale_toggle)
nmap <silent> <leader>ao :ALEOrganizeImports<cr>
nmap <silent> <leader>ac <Plug>(ale_documentation)
nmap <silent> <leader>ar <Plug>(ale_find_references)
nmap <silent> <leader>ag <Plug>(ale_go_to_definition)
nmap <silent> <leader>as <Plug>(ale_go_to_definition_in_split)
nmap <silent> <leader>av <Plug>(ale_go_to_definition_in_vsplit)
nmap <silent> <leader>ab <Plug>(ale_go_to_definition_in_tab)
nmap <silent> <leader>am :ALERename<cr>
nmap <silent> <leader>ah <Plug>(ale_hover)
nmap <silent> <leader>ad <Plug>(ale_detail)

" }}}

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

" Remove the built-in colors from :Colors command
command! -bang Colors call fzf#run(fzf#wrap({
    \'source':  fzf#vim#_uniq(s:GetPluginColorschemes(0)),
    \'sink':    'colo',
    \'options': '+m --prompt="Colors> "',
\}))

" Find files within a project (marked by .git, .gitignore, setup.py etc.)
command! -bang PFiles call fzf#vim#files(s:LocateProjectRoot(3), <bang>0)

command! -bang -nargs=* GGrep
\ call fzf#vim#grep(
\   'git grep --line-number -- '.shellescape(<q-args>), 0,
\   fzf#vim#with_preview({'dir': '/Users/alexb/projects/react-native/BakerFriend'}), <bang>0)

command! -bang -nargs=* -complete=dir Dirs
\ call fzf#run(fzf#wrap({'source': 'fd --type d --color=never', 'options': ['--preview', 'tree -C -L 1 {}']}))

nnoremap <silent> <localleader>gf :GFiles<cr>

nnoremap <silent> <localleader>rg :Rg<cr>
" }}}

" vim-gitgutter {{{
nmap <silent> <leader>hn <Plug>(GitGutterNextHunk)zz
nmap <silent> <leader>hp <Plug>(GitGutterPrevHunk)zz
nmap <silent> <leader>hv <Plug>(GitGutterPreviewHunk)
nmap <silent> <leader>ht <Plug>(GitGutterBufferToogle)

let g:gitgutter_floating_window_options = {
    \'relative': 'cursor',
    \'row': 1,
    \'col': 0,
    \'width': 42,
    \'height': &previewheight,
    \'style': 'minimal',
    \'border': 'rounded'
\}
let g:gitgutter_sign_added = '┃'
let g:gitgutter_sign_modified = '┃'
let g:gitgutter_sign_removed = '┃'
let g:gitgutter_sign_modified_removed = '║'
" }}}

" git-messenger.vim {{{
let g:git_messenger_conceal_word_diff_marker = 1
" }}}

" goyo.vim {{{
" Use the width of the textwidth option as the default width for goyo
" Use a buffer of 5 for extra spaces in formatting or commented lines
let g:goyo_width = max([90, &textwidth + 5])

" Keep line numbers around when Goyo is enabled
let g:goyo_linenr = 1

" Function for toggling goyo mode since quitting goyo mode with 'q' puts the
" cursor at the top of the file
function! s:goyo_toggle() abort
    if exists('#goyo')
        silent Goyo!
    else
        " Use the width of the textwidth option as the default width for goyo
        " Use a buffer of 5 for extra spaces in formatting or commented lines
        let g:goyo_width = max([&textwidth, 80]) + 5

        silent Goyo
    endif
endfunction

" Quickly set up Goyo with a width of 50%
nnoremap <silent> <localleader>gy :call <SID>goyo_toggle()<cr>
" }}}

" lightline.vim {{{
function! CurrentColorscheme() abort
    return '  ' . g:colors_name
endfunction

function! LightlineFileTypeSymbol()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! LightlineFileFormatSymbol()
    return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

function! LightlineGitBranch()
    let head = FugitiveHead()

    if !empty(head)
        return '  ' . FugitiveHead()
    else
        return '  -' . FugitiveHead()
    endif
endfunction

function! LightlineFilename()
    return '  ' . expand('%:t')
endfunction

function! LightlineReadonly()
    let ro = &readonly

    if ro
        return ''
    else
        return ''
    endif
endfunction

function! LightlineModified()
    let modified = &modified

    if modified
        return ' '
    else
        return ''
    endif
endfunction

let g:lightline = {
    \'active': {
        \'left': [ [ 'mode', 'paste' ],
        \[ 'gitbranch', 'current_colorscheme', 'readonly', 'filename' ] ]
    \},
    \'component_function': {
        \'gitbranch': 'LightlineGitBranch',
        \'current_colorscheme': 'CurrentColorscheme',
        \'filetype': 'LightlineFileTypeSymbol',
        \'fileformat': 'LightlineFileFormatSymbol',
        \'filename': 'LightlineFilename',
        \'readonly': 'LightlineReadonly',
        \'modified': 'LightlineModified',
    \},
    \'component_type': {
        \'gitbranch': 'error',
    \},
    \'colorscheme': 'nord'
\}

let g:lightline.enable = {
    \'statusline': 1,
    \'tabline': 0
\}
" }}}

" neoformat {{{
let g:neoformat_only_msg_on_error = 1
let g:neoformat_try_node_exe = 1
" }}}

" NERDTree {{{
" Shortcut to toggle NERDTree
noremap <silent> <c-n> :NERDTreeToggle<cr>

" Ignore python bytecode files and swap files
let NERDTreeIgnore = ['\~$', '\.py[co]$', '\.sw[op]$']

" Always show hidden files
let NERDTreeShowHidden = 1

" Show line numbers
let NERDTreeShowLineNumbers = 1

" Remap keys for opening files in splits to resemble
" ':split' and ':vsplit'
let g:NERDTreeMapOpenVSplit = 'v'
let g:NERDTreeMapOpenSplit = 's'

augroup NERDTree
    autocmd WinEnter * call s:CloseNerdTreeIfOnlyWindow()

    if v:version >= 703
        " Use relative line numbering for quick navigation
        autocmd FileType nerdtree setlocal relativenumber
    endif
augroup END
" }}}

" UltiSnips {{{
" Split the :UltiSnipsEdit window horizontally or vertically depending on context
let g:UltiSnipsEditSplit = 'context'

let g:UltiSnipsSnippetDirectories = ['UltiSnips', 'custom-ultisnips']

let g:ultisnips_javascript = {
    \'keyword-spacing': 'always',
    \'semi': 'never',
    \'space-before-function-paren': 'never',
\}

" Open the snippets file for the current file type
nnoremap <leader>sf :UltiSnipsEdit!<cr>
" }}}

" vim-airline {{{
" Fancy tabs!
let g:airline#extensions#tabline#enabled = 1

" Show tab numbers
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#tab_nr_type = 1

" Do not show buffers when only a single tab is open
let g:airline#extensions#tabline#show_buffers = 0

" Use the sweet powerline fonts
let g:airline_powerline_fonts = 1

" Enable the Syntastic plugin for vim-airline
let g:airline#extensions#syntastic#enabled = 1

" Enable Tagbar annotations in the statusline
let g:airline#extensions#tagbar#enabled = 1

" Limit the length of long branch names (appends '...')
let g:airline#extensions#branch#displayed_head_limit = 32
" }}}

" vim-devicons {{{
let g:DevIconsEnableFoldersOpenClose = 1
" let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {}
" let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['mysql'] = g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['sql']
" }}}

" vim-easy-align {{{
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" }}}

" vim-fugitive {{{
" Useful git mappings based on the spf13-vim distribution
nnoremap <silent> <leader>gs :G<cr>
nnoremap <silent> <leader>gd :Gdiffsplit<cr>
nnoremap <silent> <leader>gc :G commit<cr>
nnoremap <silent> <leader>gb :G blame<cr>
nnoremap <silent> <leader>gl :Term git log<cr>
nnoremap <silent> <leader>gp :G push<cr>
nnoremap <silent> <leader>gv :vert G --paginate diff --cached<cr>
nnoremap <silent> <leader>gw :Gwrite<cr>
nnoremap <silent> <leader>gu :GBrowse!<cr>
xnoremap <silent> <leader>gu :GBrowse!<cr>

" Define a command and mapping for viewing staged changes
command! Gcached :Gtabedit! diff --cached
nnoremap <silent> <leader>gr :Gcached<cr>
" }}}

" vim-startify {{{
if &encoding == 'utf-8'
    let g:startify_fortune_use_unicode = 1
endif

let g:startify_custom_header_quotes = [
    \['The optimal allocation is one that never happens.', '', '- Joseph E. Hoag'],
    \['Design is, as always, the art of finding compromises.', '', '- Eric Lippert']
\] + startify#fortune#predefined_quotes()
let g:startify_disable_at_vimenter = 1
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
if has('nvim')
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
