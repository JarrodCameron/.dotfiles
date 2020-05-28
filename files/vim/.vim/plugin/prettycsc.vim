" cscope -d -L3list_iter_init | awk '{print $1 ":" $3}'
"
" print bat/iter.c, highlight line 40
" bat src/iter.c -H 40
"
" number of lines:
" system(tput lines)
"
" From docs
" map g<C-]> :cs find 3 <C-R>=expand("<cword>")<CR><CR>
" map g<C-\> :cs find 0 <C-R>=expand("<cword>")<CR><CR>

function! g:CscDef(cword)
	" mktemp adds a '\n' so we need to trim it off
	let l:tempin = system('mktemp')[:-2]
	let l:tempout = system('mktemp')[:-2]

	" Run cscope from the command line
	call system('cscope -d -L1' . a:cword . ' > ' . l:tempin)

	"TODO If there are no matches then just return after cleaning temp files"

	let l:preview = "--preview='~/.vim/shell/preview.sh {1} {3}'"
	let l:command = 'fzf ' . l:preview . ' < ' . l:tempin . ' > ' . l:tempout
	execute 'silent !' . l:command

	redraw!

	let l:choice = readfile(l:tempout)
	if l:choice == []
		" TODO Rm temp files"
		return
	endif

	let l:chosen_file = split(l:choice[0], ' ')[0]
	let l:chosen_line = split(l:choice[0], ' ')[2]

	execute 'silent edit ' . l:chosen_file

	" TODO Set the cursor position in the file"
"	setpos -> Set the position of the cursor, setpos('.', []). The list is
"		changed and is from getcurpos
"	getcurpos -> This function is the function needed to get the current
"		position will will be modified

" TODO Remove temp files"
endfunction

"command! P call s:cmd()

"nnoremap <silent> <C-]> :call g:CscDef(expand("<cword>"))<CR>

