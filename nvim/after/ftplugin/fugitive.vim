nnoremap <silent> <buffer> cvv :<c-u>vert G commit<cr>
nnoremap <silent> <buffer> - <Plug>fugitive:-zz

" I go to unstaged files way more often than untracked files
nnoremap <silent> <buffer> gu <Plug>fugitive:gU
nnoremap <silent> <buffer> gU <Plug>fugitive:gu

nnoremap <silent> <buffer> s <Plug>fugitive:o
nnoremap <silent> <buffer> v <Plug>fugitive:gO
nnoremap <silent> <buffer> t <Plug>fugitive:O
