nnoremap <silent> <buffer> cvv :<c-u>vert G commit<cr>
nnoremap <silent> <buffer> - <Plug>fugitive:-zz

" I go to unstaged files way more often than untracked files
nnoremap <silent> <buffer> gu <Plug>fugitive:gU
nnoremap <silent> <buffer> gU <Plug>fugitive:gu
