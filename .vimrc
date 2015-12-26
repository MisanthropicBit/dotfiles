" Tell vim to check 1 line for file-specific settings (see last line)
set modelines=1

" General {{{

" Ignore backwards compatibility to vi
set nocompatible

" Always display current mode
set showmode

" Show line numbers
set number

" Prefer utf-8
set encoding=utf8

" Enable syntax highlighting
syntax on

" Set margin for the zt and zb commands
set scrolloff=3

" Allow mouse clicks to change cursor position
if has('mouse')
    set mouse=a
endif

" No sounds on errors
set noerrorbells

" }}}

" Colors {{{

" Enable 256 color mode
set t_Co=256

" Set the default colorscheme
try
    colorscheme jellybeans
catch
endtry

" }}}

" Searching {{{

" Highlight searches
set hlsearch

" Use incremental search
set incsearch

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

nmap <C-t> :tabnew<cr>

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

" Mappings {{{

" Move vertically while ignoring true lines
nnoremap j gj
nnoremap k gk

" Redraw the screen and remove any highlighting
nnoremap <silent> <C-l> :nohl<CR><C-l>

" Auto-close curly brackets after pressing [Enter]
inoremap {<CR> {<CR>}<C-o>O

" }}}

" Folding {{{

" Disable folding by default
set nofoldenable

" Using indentation to determine folding
set foldmethod=indent

" Maximum nesting for folds is 3
set foldnestmax=3

" }}}

" File-specific settings {{{

" Use the filetype plugin
filetype plugin on

" Use C-style indentation rules for C/C++/CUDA
autocmd FileType c setlocal cindent
autocmd FileType cpp setlocal cindent
autocmd FileType cuda setlocal cindent

" Use Python syntax for SCons files
au BufReadPost SCons* set syntax=python
autocmd BufRead,BufNewFile *.scons set filetype=python

" Highlight text if it goes over 80 columns in Python
autocmd FileType python set colorcolumn=80
autocmd FileType python highlight ColorColumn ctermbg=235 guibg=#2c2d27

" Using javascript highlighting for json files
autocmd BufRead,BufNewFile *.json set filetype=javascript

" Using html highlighting for handlebars files
autocmd BufRead,BufNewFile *.hbs set filetype=html

" Enable spell-checking for Latex files
autocmd FileType tex set spell spelllang=en_gb

" Automatically delete trailing whitespace when saving Python files
autocmd BufWrite *.py :call DeleteTrailingWhitespace()

" }}}

" Leader shortcuts {{{

" Set leader character
let mapleader=","

" Display the syntax group(s) of the current word
nmap <leader>sg :call <SID>SynStack()<CR>

" Shortcut for disabling highlighting
map <silent> <leader><space> :nohl<cr>

" Quickly toggle paste mode
map <leader>pp :setlocal paste!<cr>

" }}}

" Explorer {{{

" Show stats in :Explorer mode
let g:netrw_liststyle=3

" }}}

" Functions {{{

" Show syntax group for current word
function! <SID>SynStack()
    if !exists("*synstack")
        return
    endif

    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" Remember last editing position
if has("autocmd")
    autocmd BufReadPost *
        \ if line("'\"") > 1 && line("'\"") <= line("$") |
        \   exe "normal! g`\"" |
        \ endif
endif

" Function that deletes trailing whitespace
func! DeleteTrailingWhitespace()
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfunc

" }}}

" vim:foldenable:foldmethod=marker:foldlevel=0
