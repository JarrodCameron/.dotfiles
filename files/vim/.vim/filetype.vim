" This file is used to detect the file type manually incase vim doesn't

if exists("did_load_filetypes")
    finish
endif

augroup filetypedetect
    " Don't remove the '!'
    autocmd! BufRead,BufNewFile gdbinit        setfiletype gdb
    autocmd! BufRead,BufNewFile DESIGN         setfiletype markdown
    autocmd! BufRead,BufNewFile xmobarrc       setfiletype haskell
    autocmd! BufRead,BufNewFile config         setfiletype conf
    autocmd! BufRead,BufNewFile dunstrc        setfiletype cfg
    autocmd! BufRead,BufNewFile .todo          setfiletype conf
    autocmd! BufRead,BufNewFile *.rr2          setfiletype conf
    autocmd! BufRead,BufNewFile *.xyz          setfiletype drawing
augroup END
