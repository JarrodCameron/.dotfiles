
function! s:runCompiler()
"    if filereadable("Makefile") == 0
"        return
"    endif
    execute 'make'
    execute 'below cwindow'
endfunction

" A regexp match
if expand("%:p") =~# "cs3231"
    " Use tabs for os161
    setlocal noexpandtab
endif

" Set up brackets for multi line comment
inoremap <buffer> <leader>c /*<space><space>*/<left><left><left>

" Async stuff
"https://vim.fandom.com/wiki/Execute_external_programs_asynchronously_under_Windows#Getting_results_back_into_Vim

"autocmd BufWritePost *.c silent :call s:runCompiler() | redraw!

iabbrev <buffer> ul unsigned long
