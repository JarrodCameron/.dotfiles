" This file is used to detect the file type manually incase vim doesn't

if exists("did_load_filetypes")
    finish
endif

augroup filetypedetect
    " Don't remove the '!'
    autocmd! BufRead,BufNewFile gdbinit        setfiletype gdb
    autocmd! BufRead,BufNewFile xmobarrc       setfiletype haskell
    autocmd! BufRead,BufNewFile *.xyz          setfiletype drawing
augroup END
