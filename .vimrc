" Author: Alexander Asp Bock
" Source: https://github.com/MisanthropicBit/dotfiles

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

" Set file patterns to ignore in the wildmenu
set wildignore+=.hg,.git,.svn                                 " Version control files
set wildignore+=*.aux,*.bbl,*.bcf,*.blg,*.run.xml,*.out,*.toc " LaTeX files
set wildignore+=*.jpeg,*.jpg,*.bmp,*.gif,*.png,*.tiff         " Image files
set wildignore+=*.o,*.obj,*.exe,*.dll,*.*.manifest            " Object files
set wildignore+=*.sw?                                         " vim swap files
set wildignore+=*.pyc                                         " Python bytecode files
set wildignore+=*.class                                       " Java class files

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

" }}}

" Colors {{{

" Enable 256 color mode
if !has('gui_running')
    set t_Co=256
endif

" Set the default colorscheme
try
    colorscheme quantum
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

" Display everyting in &runtimepath on separate lines
nnoremap <silent> <leader>rtp :echo "Plugins:\n" . join(<SID>GetPluginNames(), "\n")<cr>

" Delete trailing whitespace (should this be an autocommand on saving/exiting?)
nnoremap <silent> <leader>rw :call <SID>DeleteTrailingWhitespace()<cr>

" Open manpage (default) for the word under the cursor (since K is remapped to
" moving lines upwards)
nnoremap <silent> <leader>k K

" Short-cut for 'goto tag' if tags are available through ctags
nnoremap <silent> <leader>gt <c-]>

" }}}

" Searching {{{

" Highlight searches
set hlsearch

" Use incremental search
set incsearch

" Do not jump forward to the next match when searching for the current word
nnoremap <silent> * *N

" Center the next or previous search matches
nnoremap n nzvzz
nnoremap N Nzvzz

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

" Open up to 15 tabs, instead of 10, with the '-p' option
set tabpagemax=15

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

" Only close folds that are at level 3 or higher
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
    " Automatically resize windows when vim is resized
    autocmd VimResized * :tabdo :wincmd =

    augroup trailing
        " Show trailing whitespace when not in insert mode
        autocmd!
        autocmd InsertEnter * :set listchars-=trail:⌴,nbsp:¬
        autocmd InsertLeave * :set listchars+=trail:⌴,nbsp:¬
    augroup END

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
        autocmd FileType python setlocal colorcolumn=80 textwidth=79

        " Automatically delete trailing whitespace when saving Python files
        autocmd BufWrite *.py :call <SID>DeleteTrailingWhitespace()
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
      " Use 'zv' to open just enough folds for the line to be visible and
      " 'zz' to center the line
      autocmd BufReadPost *
          \ if line("'\"") > 1 && line("'\"") <= line("$") |
          \   execute 'normal! g`"zvzz' |
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

" Open Dictionary.app on mac systems
function! OpenDictionary(...)
    let word = ''

    if a:1 !=# ''
        let word = a:1
    else
        let word = shellescape(expand('<cword>'))
    endif

    " Handle missing file and "no application can open ..." errors
    call system("open dict://" . word)
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

function! s:GetPluginNames()
    " Remove stuff not in .vim/bundle/, get the tail of the paths and sort them
    let plugins = sort(map(filter(split(&runtimepath, ","), 'v:val =~# "bundle"'), 'fnamemodify(v:val, ":t")'))

    " Remove after directories
    return filter(plugins, 'v:val !~# "after"')
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

" Enable Tagbar annotations in the statusline
let g:airline#extensions#tagbar#enabled = 1

" Limit the length of long branch names (appends '...')
let g:airline#extensions#branch#displayed_head_limit = 32

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

" vim-fugitive {{{
" Useful git mappings based on the spf13-vim distribution
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gl :Glog<cr>
nnoremap <leader>gp :Git push<cr>
" }}}

" Syntastic {{{

" Check syntax when opening files
let g:syntastic_check_on_open = 1

" Do not run checks on scala files because 'fsc' and 'scala' are too slow
"let g:syntastic_mode_map = {
"    \'mode': 'active',
"    \'passive_filetypes': ['scala']
"\}

" Set unicode symbols
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_style_warning_symbol = '⚡'
let g:syntastic_style_error_symbol = '⛔'

" Enable checkers for Syntastic using various linters and compilers
let g:syntastic_python_checkers = ['flake8', 'pep257']

let g:syntastic_c_checkers = ['clang']
let g:syntastic_cpp_checkers = ['clang++']
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = '-std=c++11 -stdlib=libc++'

let g:syntastic_cs_checkers = ['mcs']

let g:tex_flavor = 'tex'
let g:syntastic_plaintex_checkers = ['lacheck']

let g:syntastic_scala_fsc_options = '-Ystop-after:parser'
let g:syntastic_scala_checkers = ['fsc']

let g:syntastic_haskell_checkers = ['hlint']

let g:syntastic_fsharp_checkers = ['syntax']

" }}}

" UltiSnips {{{

" Set the private UltiSnips directory
let g:UltiSnipsSnippetDirectories = '~/.vim/bundle/ultisnips/UltiSnips'
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

" Shortcut mapping for viewing (r)ecently (u)sed files
nnoremap <localleader>ru :CtrlPMRUFiles<cr>

" Shortcut mapping for viewing and (s)earching for (t)ags
nnoremap <localleader>st :CtrlPTag<cr>

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

" vim-easy-align {{{

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" }}}

" ag {{{

if executable('ag')
    " Mapping for the silver searcher
    nnoremap <leader>a :Ag<space>
    let g:ackprg = 'ag --smart-case --nocolor --column'

    " This speeds up CtrlP searches significantly
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

" }}}

" vim-fsharp {{{

let g:fsharp_only_check_errors_on_write = 1

" }}}

" }}}

" vim: foldenable foldmethod=marker foldlevel=0
