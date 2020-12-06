" let choice =  confirm("Interperter", "&python3\n&dash", 1)

function! s:AAA() range
	let choice =  confirm("Interperter", "&python3\n&sh", 1)
	if choice == '1'
		let interpreter = "python3"
	elseif choice == '2'
		let interpreter = "/bin/sh -c"
	else
		echom "Unkown interpreter\n"
		return
	endif
	" TODO do shit"
	echom "asdf\n"
endfunction

vnoremap ,i :call <SID>AAA()

