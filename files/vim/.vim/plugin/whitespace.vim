" Clears white space in a file when being saved.
" Also restores cursor position to same line.

function! s:clearwhitespace()
	let l:pos = getpos('.')
	let l:lnum = l:pos[1]

	" Clear the white space
	execute "normal :%s/\\s\\+$//e\<CR>"

	" New column number is reduced iff our cursor was in the the "whitespace"
	let l:pos[2] = min([l:pos[2], len(getline(l:lnum))])

	" Restore previous line number
	call setpos('.', l:pos)
endfunction

autocmd BufWritePre * call s:clearwhitespace()
