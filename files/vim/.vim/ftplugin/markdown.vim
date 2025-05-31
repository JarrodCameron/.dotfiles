set expandtab
set tabstop=2
set foldmethod=manual

" Set up brackets for multi line comment
inoremap <buffer> <leader>c <!--<space><space>--><left><left><left><left>

noremap <silent> <C-l> :call ToggleTask()<CR>
inoremap <silent> <C-l> <ESC>:call ToggleTask()<CR>

function! ToggleTask()

	let curline = getline('.')

	if curline !~ '^\s*- \[.\]' " Line without checkbox
		call setline('.', '- [ ] '.curline)
		let pos = getpos('.')
		let pos[2] += len('- [ ] ')
		call setpos('.', pos)
	elseif curline =~ '^\s*- \[ \] '
		let newline = substitute(curline, "- \\[ \\]", "- [x]", '')
		call setline('.', newline)
	elseif curline =~ '^\s*- \[.\] '
		let newline = substitute(curline, "- \\[.\\]", "- [ ]", '')
		call setline('.', newline)
	endif
endfunction
