" Pathogen {{{

" Update runtimepath with plugins from ~/.vim/bundle/
execute pathogen#infect()

" Generate help tags
execute pathogen#helptags()

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

" }}}

" Colors {{{

" Enable 256 color mode
if !has('gui_running')
    set t_Co=256
endif

" Set the default colorscheme
try
    colorscheme hybrid
catch
endtry

" }}}

" Mappings {{{

" Set leader character
let mapleader = "\<space>"

" Set the local leader character
let maplocalleader = "\<space>"

" Display the syntax group(s) of the current word
nnoremap <leader>sg :call <SID>SynStack()<cr>

" Shortcut for disabling highlighting
nnoremap <silent> <leader><space> :nohl<cr>

" Quickly toggle paste mode
nnoremap <silent> <leader>pp :setlocal paste!<cr>

" Tab navigation shortcuts
nnoremap <leader>h gT
nnoremap <leader>l gt

" Quickly save the current buffer
nnoremap <leader>w :w<cr>

" Quickly close the current buffer
nnoremap <leader>q :q<cr>

" Shortcut for correcting a misspelled word with its first suggestion
nnoremap <leader>1 1z=

" Count and display the occurrences of <cword>
nnoremap <silent> <leader>o :%s/<c-r><c-w>//gn<cr>

" Move vertically while ignoring true lines
nnoremap j gj
nnoremap k gk

" Auto-close curly brackets after pressing [Enter]
inoremap {<cr> {<cr>}<C-o>O

" Shortcut for editing the vimrc file
nnoremap <leader>vh :sp $MYVIMRC<cr>
nnoremap <leader>vv :vsp $MYVIMRC<cr>

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

" Yank from cursor to the end of line instead of the entire line
nnoremap Y y$

" Shortcut for calling '!make'
nnoremap <leader>m :!make<cr>

" Quicker way to increment and decrement numbers
" Mnemonics: [u]p and [d]own
nnoremap <leader>u <c-a>
nnoremap <leader>d <c-x>

" Quickly toggle folds
nnoremap <leader>f za

" Quickly toggle relative line numbering
if v:version >= 703
    nnoremap <silent> <leader>n :set relativenumber!<cr>
endif

" Quicker way to exit insert mode
inoremap jk <esc>

" }}}

" Searching {{{

" Highlight searches
set hlsearch

" Use incremental search
set incsearch

" Do not jump forward to the next match when searching for the current word
nnoremap <silent> * *N

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

" Change two vertically split windows to a horizontal layout
" Mnenomic: Swap Windows to Horizontal
nnoremap <leader>swh <c-w>t <c-w>K

" Change two horizontally split windows to a vertical layout
" Mnenomic: Swap Windows to Vertical
nnoremap <leader>swv <c-w>t <c-w>H

" }}}

" Folding {{{

" Only close folds that are at level 4 or higher
set foldlevel=3

" Using indentation to determine folding
set foldmethod=indent

" Maximum nesting for folds is 3
set foldnestmax=3

" }}}

" Commands {{{

if has('mac') || has('macunix')
	command! -nargs=? Dict call OpenDictionary(<q-args>)
endif

" }}}

" Autocommands {{{

if has("autocmd")
    augroup clike
        " Use C-style indentation rules for C/C++/CUDA
        autocmd FileType c setlocal cindent
        autocmd FileType cpp setlocal cindent
        autocmd FileType cuda setlocal cindent
    augroup END

    augroup scons
        " Use Python syntax for SCons files
        autocmd BufReadPost SCons* setlocal filetype=python
        autocmd BufRead,BufNewFile *.scons setlocal filetype=python
    augroup END

    augroup python
        " Highlight text if it goes over 80 columns in Python
        " Alternative: http://stackoverflow.com/questions/235439/vim-80-column-layout-concerns
        autocmd FileType python setlocal colorcolumn=80
        autocmd FileType python highlight ColorColumn ctermbg=235 guibg=#2c2d27

        " Automatically delete trailing whitespace when saving Python files
        autocmd BufWrite *.py :call DeleteTrailingWhitespace()
    augroup END

    augroup json
        " Using javascript highlighting for json files
        autocmd BufRead,BufNewFile *.json setlocal filetype=javascript
    augroup END

    augroup handlebars
        " Using html highlighting for handlebars files
        autocmd BufRead,BufNewFile *.hbs setlocal filetype=html
    augroup END

    augroup latex
        " Enable spell-checking for Latex files
        autocmd FileType tex,plaintex setlocal spell spelllang=en_gb tw=90
    augroup END

    augroup makefile
        " Switch indentation to use tabs instead of spaces for makefiles
        autocmd BufRead,BufNewFile Makefile setlocal noexpandtab
    augroup END

    augroup markdown
        " Set text width to 80 and spell-checking on for markdown files
        autocmd FileType markdown setlocal tw=80
    augroup END

    augroup save_edit_position
      " Remember last editing position (see ':h last-position-jump')
      autocmd BufReadPost *
          \ if line("'\"") > 1 && line("'\"") <= line("$") |
          \   execute "normal! g`\"" |
          \ endif
    augroup END
endif

" }}}

" Shell {{{

" Allow external bash commands inside vim to use aliases etc.
"set shell=bash\ --rcfile\ ~/.bash_profile

" }}}

" Explorer {{{

" Show stats in :Explorer mode
let g:netrw_liststyle = 3

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

" Open Dictionary.app on mac systems
function! OpenDictionary(...)
	let word = ''

    if a:1 !=# ''
        let word = a:1
    else
        let word = shellescape(expand('<cword>'))
    endif

    silent execute '!open dict://' . word
	redraw!
endfunction

" Automatically close the NERDTree file explorer window
" if it is the only window left
" Credit: https://github.com/scrooloose/nerdtree/issues/21
function! s:CloseNerdTreeIfOnlyWindow()
    if exists("t:NERDTreeBufName")
        if bufwinnr(t:NERDTreeBufName) != -1
            if winnr("$") == 1
                q
            endif
        endif
    endif
endfunction

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

" }}}

" Plugins {{{
" NERDTree {{{

" Shortcut to toggle NERDTree
noremap <silent> <C-n> :NERDTreeToggle<cr>

" Always show hidden files
let NERDTreeShowHidden = 1

" Remap keys for opening files in splits to resemble
" ':split' and ':vsplit'
let g:NERDTreeMapOpenVSplit = 'v'
let g:NERDTreeMapOpenSplit = 's'

augroup NERDTree
    autocmd WinEnter * call s:CloseNerdTreeIfOnlyWindow()
augroup END

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
let g:airline_powerline_fonts=1

" Enable the Syntastic plugin for vim-airline
let g:airline#extensions#syntastic#enabled = 1

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
let g:surround_{char2nr('l')}="\\\1markup: \1{\r}"

" }}}

" Syntastic {{{

" Use flake8 for Python files
let g:syntastic_python_checkers=['flake8']

" Use clang/clang++ for C/C++
let g:syntastic_c_checkers=['clang']
let g:syntastic_cpp_checkers=['clang++']

" Enable C++11 support in clang++
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options='-std=c++11 -stdlib=libc++'

" Enable C# support using Mono
let g:syntastic_cs_checkers=['mcs']

" Enable Syntastic for plaintex files
let g:tex_flavor = 'tex'
let g:syntastic_plaintex_checkers=['lacheck']

" Enable Syntastic for Scala
let g:syntastic_scala_checkers=['fsc']

" Check syntax when opening files
let g:syntastic_check_on_open = 1

" Set unicode symbols
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_style_warning_symbol = '⚡'
let g:syntastic_style_error_symbol = '⛔'

" }}}

" UltiSnips {{{

" Set the private UltiSnips directory
let g:UltiSnipsSnippetsDir = '~/.vim/bundle/ultisnips/UltiSnips'

" Split the :UltiSnipsEdit window horizontally or vertically depending on context
let g:UltiSnipsEditSplit = 'context'

" Open the snippets file for the current file type
nnoremap <leader>sf :UltiSnipsEdit<cr>

" }}}

" neocomplete {{{

" Enable neocomplete at startup
let g:neocomplete#enable_at_startup = 1

" }}}

" CtrlP {{{

" Ignore shared libraries, class files and version control directories
let g:ctrlp_custom_ignore = {
    \ 'file': '\v\.(swp|so|dll|class)$',
    \ 'dir' : '\v[\/]\.(git|hg|svn|idea)$'
\ }

" Always show hidden files
let g:ctrlp_show_hidden = 1

" Custom root marker for manually setting the CtrlP root
let g:ctrlp_root_markers = ['.ctrlproot']

" }}}

" colorizer {{{

" colorizer is inefficient for large files (like 'eval.txt')
" so limit it to files with lines < 100
let g:colorizer_maxlines = 100

" Disable the default colorizer mapping
let g:colorizer_nomap = 1

" Custom mapping for toggling colorization
nnoremap <leader>tc <Plug>Colorizer

" }}}

" vim-task {{{

let g:vimtask#fancy_arrows = 1

let g:vimtask#note_foldtext = ' (notes)'

" }}}
" }}}

" vim: foldenable foldmethod=marker foldlevel=0
