" use grep (ripgrep) to find patterns and open files at that location
"
" NOTE: This does not work if a file name contains a ':'
"
" example
" rg --vimgrep '\->\s*active\s*=' 2>/dev/null

"	let l:preview = "--preview='~/.vim/shell/preview.sh {1} {3}'"
"	let l:command = 'fzf ' . l:preview . ' < ' . l:tempin . ' > ' . l:tempout
"	execute 'silent !' . l:command

function! s:RunFzf(infile, outfile)
	let l:preview = "--preview='~/.vim/shell/vimgrep-preview.sh {1} {3}'"
	let l:command = 'fzf ' . l:preview . ' < ' . a:infile . ' > ' . a:outfile
	execute 'silent !' . l:command
endfunction

function! g:VimRgInput()
	" not really sure what to do if the user sends a SIGINT...
	call inputsave()
	let l:r = input('Enter regex: ')
	call inputrestore()

	call g:VimRg(l:r)
endfunction

function! g:VimRg(i)

	let l:r = a:i

	let l:grep_file = system('mktemp')[:-2]
	let l:choice_file = system('mktemp')[:-2]

	" maybe we should blacklist some files (eg tags, cscope.out, .git/)
	let l:cmd = 'rg --vimgrep ' . shellescape(r)
	let l:cmd = l:cmd . ' > ' . l:grep_file . ' 2>/dev/null'
	call system(l:cmd)

	if readfile(l:grep_file) == []
		call system('rm -f ' . l:grep_file . ' ' . l:choice_file . ' &')
		" Make the screen look less crappy
		redraw!

		echo 'No matches for the expression: ' . l:r
		return
	endif

	call s:RunFzf(l:grep_file, l:choice_file)

	let l:choice = readfile(l:choice_file)
	if l:choice == []
		call system('rm -f ' . l:grep_file . ' ' . l:choice_file . ' &')
		" Make the screen look less crappy
		redraw!
		return
	endif

	let l:chosen_file = split(l:choice[0], ':')[0]
	let l:chosen_line = split(l:choice[0], ':')[1]
	let l:chosen_col = split(l:choice[0], ':')[2]

	execute 'silent edit ' . l:chosen_file

	let l:pos = getcurpos()
	let l:pos[1] = l:chosen_line
	let l:pos[2] = l:chosen_col
	call setpos('.', l:pos)

	" Make the screen look less crappy
	redraw!

	call system('rm -f ' . l:grep_file . ' ' . l:choice_file . ' &')

endfunction

nnoremap <silent> ,g :call g:VimRgInput()<CR>
nnoremap <silent> ,G :call g:VimRg(expand("<cword>"))<CR>
