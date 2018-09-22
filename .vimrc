" Author: Alexander Asp Bock
" Source: https://github.com/MisanthropicBit/dotfiles

" Pathogen {{{

let g:pathogen_disabled = ['vim-prism']

" Update runtimepath with plugins from ~/.vim/bundle/
execute pathogen#infect()

" Generate help tags
execute pathogen#helptags()

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

if has('mac') || has('macunix')
    " Open Dictionary.app on mac systems
    function! OpenDictionary(...)
        let bang = a:1
        let word = ''

        if a:2 !=# ''
            let word = a:2
        else
            let word = expand('<cword>')
        endif

        if bang
            if !(has('multi_byte') && (has('python') || has('python3')))
                echoerr "Dict! needs +multi_byte and +python or +python3"
                return
            endif

            " Echo the definition
            python << EOF
import DictionaryServices as ds
import sys
import vim

sword = vim.eval('word').decode('utf-8')
result = ds.DCSCopyTextDefinition(None, sword, (0, len(sword)))

if not result:
    print("No result for '{0}' found in dictionary".format(sword))
else:
    result = result.encode('utf-8')
    result = result.replace('▶', '\n\n▶ ')
    result = result.replace('•', '\n    •')
    result = result.replace('ORIGIN', '\n\nORIGIN:')
    print(result)
EOF
        else
            " Handle missing file and "no application can open ..." errors
            call system(printf('open dict://"%s"', word))
        endif
    endfunction
endif

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

" Return an alphabetically sorted list of all the currently installed plugins
function! s:GetPluginNames(regex)
    " Remove stuff not in .vim/bundle/, get the tail of the paths and sort them
    let plugins = sort(map(filter(split(&runtimepath, ","), 'v:val =~# "bundle"'),
                          \'fnamemodify(v:val, ":t")'))

    if empty(a:regex)
        return filter(plugins, 'v:val !~# "after"')
    endif

    return filter(plugins, 'v:val !~# "after" && v:val =~# "' . a:regex . '"')
endfunction

let s:builtin_colorschemes = ['blue', 'darkblue', 'default', 'delek', 'desert', 'elflord',
                             \'evening', 'koehler', 'morning', 'murphy', 'pablo', 'peachpuff',
                             \'slate', 'shine', 'torte', 'zellner']

" For use in s:RandomColorscheme. Lists colorschemes that are broken or do not
" support true-color
let s:exclude_colorschemes = ['one-dark', 'hybrid', 'ron', 'tayra', 'charcoal_candy']

" Find and choose and random user-defined colorscheme
function! s:RandomColorscheme()
    let colorschemes = map(split(globpath(&runtimepath, 'colors/*.vim'), '\n'),
                          \'fnamemodify(v:val, ":t:r")')

    let exclude = []

    if exists("s:builtin_colorschemes")
        let exclude += s:builtin_colorschemes
    endif

    if exists("s:exclude_colorschemes")
        let exclude += s:exclude_colorschemes
    endif

    let user_colorschemes = filter(colorschemes,
                                  \'index(exclude, v:val) == -1')

    let random = system('echo $RANDOM') % len(user_colorschemes)
    let chosen = get(user_colorschemes, random)

    execute ':colorscheme ' . chosen

    return chosen
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
set wildignore+=.hg,.git,.svn                           " Version control files
set wildignore+=*.aux,*.bbl,*.bcf,*.blg,*.run.xml,*.toc " LaTeX files
set wildignore+=*.jpeg,*.jpg,*.bmp,*.gif,*.png,*.tiff   " Image files
set wildignore+=*.o,*.obj,*.exe,*.dll,*.*.manifest      " Object files
set wildignore+=*.sw?                                   " vim swap files
set wildignore+=*.pyc                                   " Python bytecode files
set wildignore+=*.class                                 " Java class files
set wildignore+=*.fdb_latexmk,*.fls                     " Latexmk build files

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

" Set the default colorscheme
"try
"    colorscheme quantum
"catch
"endtry

call <SID>RandomColorscheme()

" Enable syntax highlighting
syntax on

" Default to using bash syntax highlighting
let g:is_bash = 1

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

" Yank from cursor to the end of line instead of the entire line
nnoremap Y y$

" Shortcut for calling '!make'
nnoremap <leader>m :silent !make<cr>

" Quickly toggle folds
nnoremap <leader>f za

" Quickly toggle relative line numbering
if v:version >= 703
    nnoremap <silent> <leader>n :set relativenumber!<cr>
endif

" Quicker way to exit insert mode
inoremap jk <esc>

" Display everyting in &runtimepath on separate lines
nnoremap <silent> <leader>rtp :echo "Plugins:\n" . join(<SID>GetPluginNames(''), "\n")<cr>

" Delete trailing whitespace (should this be an autocommand on saving/exiting?)
nnoremap <silent> <leader>rw :call <SID>DeleteTrailingWhitespace()<cr>

" Open manpage (default) for the word under the cursor (since K is remapped to
" moving lines upwards)
nnoremap <silent> <leader>k K

" Short-cut for 'goto tag' if tags are available through ctags
nnoremap <silent> <leader>gt <c-]>

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

" Open file under cursor in a vertical split
nnoremap <c-w>gv :vertical wincmd f<cr>

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
    command! -bang -nargs=? Dict call OpenDictionary(<bang>0, <q-args>)
endif

command! -nargs=? Plugins :echo "Plugins:\n" . join(<SID>GetPluginNames(<q-args>), "\n")
command! RandomColorscheme :echo printf("Selected: %s", <SID>RandomColorscheme())

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

    augroup quickfix
        autocmd!
        autocmd QuickFixCmdPost vimgrep cwindow

        " Mappings to open the error under the cursor in a split, vertical
        " split or new tab (there is also the QFEnter plugin)
        autocmd FileType qf nnoremap <buffer> s <c-w><cr>
        autocmd FileType qf nnoremap <buffer> v <c-w><cr><c-w>L
        autocmd FileType qf nnoremap <buffer> t <c-w><cr><c-w>T
    augroup END

    augroup csharp
        autocmd!
        autocmd FileType cs nnoremap <buffer> <silent> <localleader>ot :OmniSharpTypeLookup<cr>
                         \| nnoremap <buffer> <silent> <localleader>od :OmniSharpGotoDefinition<cr>
                         \| nnoremap <buffer> <silent> <localleader>ou :OmniSharpFindUsages<cr>
                         \| nnoremap <buffer> <silent> <localleader>or :OmniSharpRename<cr>
                         \| nnoremap <buffer> <silent> <localleader>os :OmniSharpFindSymbol<cr>
                         \| :silent OmniSharpHighlightTypes

        autocmd CompleteDone *.cs call OmniSharp#ExpandAutoCompleteSnippet()
    augroup END

    if has('conceal')
        augroup task
            autocmd!
            autocmd FileType task setlocal conceallevel=2
        augroup END
    endif
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

" {{{ Neovim
if has('nvim')
    " Enable interactive command line substitution without window splitting
    set inccommand=nosplit

    " Point neovim to its specific python virtual environments
    let g:python_host_prog = '/Users/albo/.neovim_venvs/neovim2/bin/python'
    let g:python3_host_prog = '/Users/albo/.neovim_venvs/neovim3/bin/python'
endif
" }}}

" Plugins {{{

" ag {{{

if executable('ag')
    " Mapping for the silver searcher
    nnoremap <leader>a :Ag<space>
    let g:ackprg = 'ag --smart-case --nocolor --column'

    " This speeds up CtrlP searches significantly
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

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

" CtrlP {{{

" Ignore shared libraries, class files and version control directories
let g:ctrlp_custom_ignore = {
    \ 'file': '\v\.(swp|so|dll|class|pyo|pyc)$',
    \ 'dir' : '\v[\/]\.(git|hg|svn|idea)$'
\ }

" Always show hidden files
let g:ctrlp_show_hidden = 1

" Custom root marker for manually setting the CtrlP root
let g:ctrlp_root_markers = ['.ctrlproot']

" Shortcut mapping for viewing (r)ecently (u)sed files
nnoremap <localleader>ru :CtrlPMRUFiles<cr>

" Shortcut mapping for searching current buffers
nnoremap <localleader>bb :CtrlPBuffer<cr>

" Shortcut mapping for viewing and (s)earching for (t)ags
nnoremap <localleader>st :CtrlPTag<cr>

" }}}

" delimitMate {{{

" Expand any pair of delimiting characters when pressing enter
let delimitMate_expand_cr = 1

" }}}

" deoplete-jedi {{{
" }}}

" deoplete.nvim {{{

let g:deoplete#enable_at_startup = 1

" }}}

" goyo.vim {{{

" Use the width of the textwidth option as the default width for goyo
" Use a buffer of 5 for extra spaces in formatting or commented lines
let g:goyo_width = max([90, &textwidth + 5])

" Keep line numbers around when Goyo is enabled
let g:goyo_linenr = 1

" Quickly set up Goyo with a width of 50%
nnoremap <localleader>gy :Goyo 50%<cr>

" }}}

" jedi-vim {{{

" Disable jedi-vim and use deoplete-jedi instead (we still want to use its
" mappings though)
let g:jedi#completions_enabled = 0

" Avoid clash with vim-fugitive mappings
nnoremap <leader>ga :call jedi#goto_assignments()<cr>
nnoremap <leader>ge :call jedi#goto_definitions()<cr>

let g:jedi#use_tabs_not_buffers = 1

" Disable preview when autocompleting
augroup jedivim
    autocmd!
    autocmd FileType python setlocal completeopt-=preview
augroup END

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

" omnisharp-vim {{{

" Enable snippet completion on return type and method arguments (via Ultisnips)
"let g:OmniSharp_want_snippet = 1
let g:OmniSharp_want_return_type = 1
let g:OmniSharp_want_method_header = 1

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
let g:syntastic_c_checkers = ['clang', 'gcc']
let g:syntastic_cpp_checkers = ['clang++']
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = '-std=c++11 -stdlib=libc++'
let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues', 'mcs']
let g:tex_flavor = 'tex'
let g:syntastic_plaintex_checkers = ['lacheck']
let g:syntastic_scala_fsc_options = '-Ystop-after:parser'
let g:syntastic_scala_checkers = ['fsc']
let g:syntastic_haskell_checkers = ['hlint']
let g:syntastic_fsharp_checkers = ['syntax']

" }}}

" Tagbar {{{

" Set the path to the Exuberant version of ctags
let g:tagbar_ctags_bin = '/usr/local/Cellar/ctags/5.8_1/bin/ctags'

" Make it easier to navigate in the Tagbar window
let g:tagbar_show_linenumbers = 2

" Toggle the Tagbar window
nnoremap <c-b> :TagbarToggle<cr>

" }}}

" UltiSnips {{{

" Set the private UltiSnips directory
let g:UltiSnipsSnippetsDir = '~/.vim/bundle/vim-snippets/UltiSnips'

" Split the :UltiSnipsEdit window horizontally or vertically depending on context
let g:UltiSnipsEditSplit = 'context'

" Open the snippets file for the current file type
nnoremap <leader>sf :UltiSnipsEdit<cr>

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

" vim-choosewin {{{

" Map '-' to visually choosing a window to jump to
nnoremap - <Plug>(choosewin)

" Mapping for quickly swapping two windows
nnoremap <localleader>swc :ChooseWinSwap<enter>

" Enable window overlay characters
let g:choosewin_overlay_enable = 1

" }}}

" vim-easy-align {{{

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" }}}

" vim-fsharp {{{

let g:fsharp_only_check_errors_on_write = 1

" Remap F# type-checking to avoid clashing with vim-task mappings
let g:fsharp_map_typecheck = 'y'

" }}}

" vim-fugitive {{{
" Useful git mappings based on the spf13-vim distribution
nnoremap <leader>gs :Gstatus<cr>
nnoremap <leader>gd :Gdiff<cr>
nnoremap <leader>gc :Gcommit<cr>
nnoremap <leader>gb :Gblame<cr>
nnoremap <leader>gl :Glog<cr>
nnoremap <leader>gp :Git push<cr>

" Define a command and mapping for viewing staged changes
command! Gcached :Gtabedit! diff --cached
nnoremap <leader>gr :Gcached<cr>

" Mappings for diffput and diffget
xnoremap <localleader>dp :diffput<cr>
xnoremap <localleader>dg :diffget<cr>
" }}}

" vim-startify {{{
if &encoding == 'utf-8'
    let g:startify_fortune_use_unicode = 1
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

" vim-task {{{

let g:vimtask#enable_mappings = 1
let g:vimtask#fancy_arrows = 1
let g:vimtask#notes_only_foldtext = ' (notes)'
let g:vimtask#automove_completed_tasks = 1
let g:vimtask#automove_cancelled_tasks = 1
let g:vimtask#search_paths = ['~/phd/tasks']
let g:vimtask#archive_mode = 2
let g:vimtask#done_symbol = '✔'
let g:vimtask#todo_symbol = '☐'
let g:vimtask#cancelled_symbol = '✗'
let g:vimtask#bullet_symbols = ['•', '◦', '‣', '▹']

" vimtex {{{

let g:vimtex_fold_enabled = 1

" Use Skim for viewing PDFs
let g:vimtex_view_general_options = '-a Skim'

" Disable auto viewing to keep writing
let g:vimtex_view_automatic = 0

" Disable continuous mode
let g:vimtex_compiler_latexmk = {
    \'backend' : 'jobs',
    \'background' : 1,
    \'build_dir' : '',
    \'callback' : 1,
    \'continuous' : 0,
    \'executable' : 'latexmk',
    \'options' : [
    \    '-pdf',
    \    '-verbose',
    \    '-file-line-error',
    \    '-synctex=1',
    \    '-interaction=nonstopmode',
    \],
\}

" Switch to neovim's job control if applicable
if has('nvim')
    let g:vimtex_compiler_latexmk.backend = 'nvim'
endif

" Do not open the quickfix window automatically since there are usually just
" warnings and no errors
let g:vimtex_quickfix_mode = 0

" }}}

" }}}

" vim: foldenable foldmethod=marker foldlevel=0
