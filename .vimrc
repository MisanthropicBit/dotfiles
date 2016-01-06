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

" Display current line and column in the bottom-right corner
set ruler

augroup save_edit_position
  " Remember last editing position
  autocmd BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \   exe "normal! g`\"" |
      \ endif
augroup END

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

" Leader shortcuts {{{

" Set leader character
let mapleader=","

" Set the local leader character
let maplocalleader=","

" Display the syntax group(s) of the current word
nnoremap <leader>sg :call <SID>SynStack()<CR>

" Shortcut for disabling highlighting
noremap <silent> <leader><space> :nohl<cr>

" Quickly toggle paste mode
noremap <leader>pp :setlocal paste!<cr>

" }}}

" Searching {{{

" Highlight searches
set hlsearch

" Use incremental search
set incsearch

" Do not jump forward to the next match when searching for the current word
nnoremap * *N

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

" Auto-close curly brackets after pressing [Enter]
inoremap {<CR> {<CR>}<C-o>O

" Shortcut for editing the vimrc file
nnoremap <leader>ev :sp $MYVIMRC<cr>
nnoremap <leader>evv :vsp $MYVIMRC<cr>

" Shortcut to reload the vimrc file
nnoremap <leader>sv :source $MYVIMRC<cr>

" Easily swap the current line up and down
nnoremap J :m .+1<cr>==
nnoremap K :m .-2<cr>==

" Quicker way to exit insert mode
inoremap jk <esc>

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

augroup clike
    " Use C-style indentation rules for C/C++/CUDA
    autocmd FileType c setlocal cindent
    autocmd FileType cpp setlocal cindent
    autocmd FileType cuda setlocal cindent
augroup END

augroup scons
    " Use Python syntax for SCons files
    au BufReadPost SCons* set syntax=python
    autocmd BufRead,BufNewFile *.scons set filetype=python
augroup END

augroup python
    " Highlight text if it goes over 80 columns in Python
    autocmd FileType python set colorcolumn=80
    autocmd FileType python highlight ColorColumn ctermbg=235 guibg=#2c2d27

    " Automatically delete trailing whitespace when saving Python files
    autocmd BufWrite *.py :call DeleteTrailingWhitespace()
augroup END

augroup json
    " Using javascript highlighting for json files
    autocmd BufRead,BufNewFile *.json set filetype=javascript
augroup END

augroup handlebars
    " Using html highlighting for handlebars files
    autocmd BufRead,BufNewFile *.hbs set filetype=html
augroup END

augroup latex
    " Enable spell-checking for Latex files
    autocmd FileType tex set spell spelllang=en_gb
augroup END

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
endfunction

" Function that deletes trailing whitespace
function! DeleteTrailingWhitespace()
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfunction

" }}}

" Pathogen {{{

" Update runtimepath with plugins from ~/.vim/bundle/
execute pathogen#infect()

" }}}

" NERDTree {{{

" Shortcut to toggle NERDTree
noremap <C-n> :NERDTreeToggle<CR>

" }}}

" vim:foldenable:foldmethod=marker:foldlevel=0
