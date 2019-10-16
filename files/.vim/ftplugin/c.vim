
function! s:runCompiler()
"    if filereadable("Makefile") == 0
"        return
"    endif
    execute 'make'
    execute 'below cwindow'
endfunction

" Async stuff
"https://vim.fandom.com/wiki/Execute_external_programs_asynchronously_under_Windows#Getting_results_back_into_Vim

"autocmd BufWritePost *.c silent :call s:runCompiler() | redraw!
