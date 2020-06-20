fun! s:DetectFennel()
    if getline(1) =~# '^#!.*/bin/env\s\+fennel\>'
        setfiletype fennel
    endif
endfun

autocmd BufRead,BufNewFile *.fnl setlocal filetype=fennel
autocmd BufNewFile,BufRead * call s:DetectFennel()

" vim: et sw=2 sts=-1 tw=100 fdm=marker
