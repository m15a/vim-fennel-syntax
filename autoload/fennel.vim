" Helper functions for fennel-syntax plugin
" Last Change: 2021-06-13
" Author: Mitsuhiro Nakamura <m.nacamura@gmail.com>
" URL: https://github.com/mnacamura/vim-fennel-syntax
" License: MIT

if exists('g:autoloaded_fennel')
  finish
endif
let g:autoloaded_fennel = 1

" Get value from a buffer-local or global variable with fall back
fun! fennel#Get(varname, default) abort
  let l:prefixed_varname = 'fennel_' . a:varname
  return get(b:, l:prefixed_varname, get(g:, l:prefixed_varname, a:default))
endfun

" vim: et sw=2 sts=-1 tw=100 fdm=marker
