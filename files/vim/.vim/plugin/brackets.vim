function! s:insertopen(open, close)
    let l:curr = getline('.')[col('.')-1]
    if l:curr == a:open
        return "\<right>"
    elseif index(['(', '[', '{'], l:curr) < 0
        return a:open . a:close . "\<left>"
    else
        return a:open
    endif
endfunction

function! s:insertclose(close)
    if getline('.')[col('.')-1] == a:close
        return "\<right>"
    else
        return a:close
    endif
endfunction

function! s:insertquote(quote)
    if getline('.')[col('.')-1] == a:quote
        return "\<right>"
    else
        return a:quote . a:quote . "\<left>"
    endif
endfunction

function! s:removepair()
    let l:pairs = ['()', '[]', '{}', '""', "''"]
    let l:line = getline('.')
    let l:col = col('.')
    if index(l:pairs, l:line[l:col-2 : l:col-1]) < 0
        return "\<bs>"
    else
        return "\<bs>\<del>"
    endif
endfunction

inoremap <expr> ( <SID>insertopen('(', ')')
inoremap <expr> [ <SID>insertopen('[', ']')
inoremap <expr> { <SID>insertopen('{', '}')

inoremap <expr> ) <SID>insertclose(')')
inoremap <expr> ] <SID>insertclose(']')
inoremap <expr> } <SID>insertclose('}')

" Not clean but it works
inoremap {<CR> {<CR>}<ESC>O
inoremap (<CR> (<CR>)<ESC>O
inoremap [<CR> [<CR>]<ESC>O

"inoremap <expr> " <SID>insertquote('"')
"inoremap <expr> ' <SID>insertquote("'")

inoremap <expr> <bs> <SID>removepair()
