" Reverse a range of lines when using the `:Rev' command in visual mode. If
" only one line is selected when reverse each word in the line seperated by
" a space.

function! s:rev(top, bot)
	if a:top == a:bot
		let s:line = a:top
		call setline(s:line, join(reverse(split(getline(s:line), ' ')), ' '))
		return
	endif

	let s:lo = a:top
	let s:hi = a:bot
	while s:lo < s:hi

		let s:temp = getline(s:lo)
		call setline(s:lo, getline(s:hi))
		call setline(s:hi, s:temp)

		let s:lo = s:lo + 1
		let s:hi = s:hi - 1

	endwhile
endfunction

command! -range -nargs=0 Reverse call s:rev(<line1>, <line2>)
