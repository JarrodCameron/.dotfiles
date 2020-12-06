" Set up brackets for multi line comment
"inoremap <buffer> <leader>c /*<space><space>*/<left><left><left>

" do the println! thing
"inoremap <buffer> ,f println!("{:?}",<space>)<left>
"inoremap <buffer> ,f io:format("",<space>[]),<left><left><left><left><left><left><left>

function! g:DoFormat()
	let t = input("Variable: ")
	execute 'normal iio:format("' . t . ' = ~w~n", [' . t . ']),'
	echom "alksjdhflkashdf"
endfunction

inoremap <buffer> ,f <esc>:call<space>g:DoFormat()<CR>

