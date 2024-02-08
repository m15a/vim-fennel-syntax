" Vim indent file
" Language: Fennel
" Last Change: 2024-02-08
" Original Maintainer: Calvin Rose
" Maintainer: NACAMURA Mitsuhiro <m15@m15a.dev>
" URL: https://github.com/m15a/vim-fennel-syntax
" License: MIT

if exists('b:did_indent')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

setlocal autoindent nosmartindent
setlocal softtabstop=2 shiftwidth=2 expandtab

let b:undo_indent = 'setl ai< si< sts< sw< et<'

let b:did_indent = 1

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: et sw=2 sts=-1 tw=100 fdm=marker
