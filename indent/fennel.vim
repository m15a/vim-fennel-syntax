" Vim filetype plugin file
" Language: FENNEL
" Maintainer: Calvin Rose

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

let s:save_cpo = &cpo
set cpo&vim

setlocal autoindent nosmartindent
setlocal softtabstop=2 shiftwidth=2 expandtab

setlocal lisp
let b:undo_indent .= '| setlocal lisp<'

let &cpo = s:save_cpo
unlet! s:save_cpo
