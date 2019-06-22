" Insert closing bracket
function! g:InsertPair(bracket)
  if col("$") == 1 || col(".") == col("$")-1
    return
  endif
  if getline(".")[col(".")] == a:bracket
    execute "normal! x"
  endif
endfunction

" Inserts an open bracket
"function! g:InsertOpenBracket(bopen, bclose)
"    if col('$') == 2 || col('.') == col('$') - 1
"        execute 'normal! a' . a:bclose
"    elseif getline('.')[col('.')] == a:bopen
"        execute 'normal! xl'
"    endif
"    execute 'startinsert'
"endfunction
"
" Inserts a closing bracket
"function! g:InsertClosedBracket(bopen, bclose)
"    if col('$') == 2 || col('.') == col('$') - 1
"        execute 'normal! a' . a:bclose
"    elseif getline('.')[col('.')] == a:bopen
"        execute 'normal! xl'
"    endif
"    execute 'startinsert'
"endfunction

inoremap {<CR> {<CR>}<esc>O
inoremap [<CR> [<CR>]<esc>O<space><space><space><space>
inoremap (<CR> (<CR>)<esc>O<space><space><space><space>

inoremap {;<CR> {<CR>};<esc>O
inoremap [;<CR> [<CR>];<esc>O<space><space><space><space>
inoremap (;<CR> (<CR>);<esc>O<space><space><space><space>

"inoremap ( (<esc>:call g:InsertOpenBracket('(', ')')<CR>
"inoremap ) )<esc>:call g:InsertClosedBracket('(', ')')<CR>

inoremap { {}<left>
inoremap [ []<left>
inoremap ( ()<left>

inoremap } }<esc>:call g:InsertPair("}")<CR>a
inoremap ] ]<esc>:call g:InsertPair("]")<CR>a
inoremap ) )<esc>:call g:InsertPair(")")<CR>a
