
" A simple todo list manager. Using <leader>t the list of todo's can be
" updated. <C-j> and <C-k> can be used to move to the next and previous todo
" respectively

nnoremap <C-j> :cnext<CR>
nnoremap <C-k> :cprevious<CR>
nnoremap <leader>t  :vimgrep TODO **/*.[ch]<CR>
