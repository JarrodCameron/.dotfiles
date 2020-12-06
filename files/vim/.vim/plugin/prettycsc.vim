" cscope -d -L3list_iter_init | awk '{print $1 ":" $3}'

function! g:CscGeneral(operation, cword)
	let l:tempin = system('mktemp')[:-2]
	let l:tempout = system('mktemp')[:-2]

	" Run cscope from the command line
	call system('cscope -d -L' . a:operation . a:cword . ' > ' . l:tempin)

	if system('wc -c < ' . l:tempin) == "0\n"
		call system('rm -f ' . l:tempin . ' ' . l:tempout . ' &')
		return
	endif

	let l:preview = "--preview='~/.vim/shell/preview.sh {1} {3}'"
	let l:command = 'fzf ' . l:preview . ' < ' . l:tempin . ' > ' . l:tempout
	execute 'silent !' . l:command

	let l:choice = readfile(l:tempout)
	if l:choice == []
		call system('rm -f ' . l:tempin . ' ' . l:tempout . ' &')
		" Make the screen look less crappy
		redraw!
		return
	endif

	let l:chosen_file = split(l:choice[0], ' ')[0]
	let l:chosen_line = split(l:choice[0], ' ')[2]

	execute 'silent edit ' . l:chosen_file

	let l:pos = getcurpos()
	let l:pos[1] = l:chosen_line
	call setpos('.', l:pos)

	" Make the screen look less crappy
	redraw!

	call system('rm -f ' . l:tempin . ' ' . l:tempout . ' &')
endfunction

" cscope: Find this C symbol
nnoremap <silent> cs :call g:CscGeneral('0', shellescape(expand("<cword>")))<CR>

" csope: find this definition
nnoremap <silent> cd :call g:CscGeneral('1', shellescape(expand("<cword>")))<CR>

" cscope: functions calling this function
nnoremap <silent> cc :call g:CscGeneral('3', shellescape(expand("<cword>")))<CR>

