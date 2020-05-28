" Vim Treats positive and negative numbers the same
"   when doing modulus
function! s:SafeMod(n, m)
    return (a:n + a:m) % a:m
endfunction

" Changes to next tab based on location
function! g:ChangeTab(offset)
    let l:new = s:SafeMod(tabpagenr() - 1 + a:offset + tabpagenr('$'), tabpagenr('$')) + 1
    execute 'normal! ' . string(l:new) . 'gt'
endfunction

nnoremap <silent> <C-n> :call g:ChangeTab(-1)<CR>
nnoremap <silent> <C-p> :call g:ChangeTab(1)<CR>
