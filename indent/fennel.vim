" Vim indent file
" Language: Fennel
" Last Change: 2020-06-20
" Original Maintainer: Calvin Rose
" Maintainer: Mitsuhiro Nakamura <m.nacamura@gmail.com>
" URL: https://github.com/mnacamura/vim-fennel-syntax
" License: MIT

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

" vim: et sw=2 sts=-1 tw=100 fdm=marker
