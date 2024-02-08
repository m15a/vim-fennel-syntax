" Helper functions for fennel-syntax plugin
" Last Change: 2024-02-08
" Author: NACAMURA Mitsuhiro <m15@m15a.dev>
" URL: https://github.com/m15a/vim-fennel-syntax
" License: MIT

if exists('g:autoloaded_fennel_number')
  finish
endif
let g:autoloaded_fennel_number = 1

" Build regexp of decimal number.
fun! fennel#number#Dec() abort
  let l:body = s:Or(s:digits1, '\.' . s:digits1, s:digits1 . '\.' . s:digits0)
  return s:Bless(s:sign . l:body . s:Suffix('e'))
endfun

" Build regexp of hex integer (Lua 5.1).
fun! fennel#number#HexInt() abort
  let l:prefix = '_*0_*x'
  let l:body = s:xdigits1
  return s:Bless(s:sign . l:prefix . l:body)
endfun

" Build regexp of hex number.
fun! fennel#number#Hex() abort
  let l:prefix = '_*0_*x'
  let l:body = s:Or(s:xdigits1, '\.' . s:xdigits1, s:xdigits1 . '\.' . s:xdigits0)
  return s:Bless(s:sign . l:prefix . l:body . s:Suffix('p'))
endfun

let s:sign = '_*[-+]\?'

let s:digits0 = '[_[:digit:]]*'

let s:xdigits0 = '[_[:xdigit:]]*'

let s:digits1 = s:digits0 . '[[:digit:]]' . s:digits0

let s:xdigits1 = s:xdigits0 . '[[:xdigit:]]' . s:xdigits0

" Enclose items in '%( ... | ... )'.
fun! s:Or(...) abort
  let l:out = '\%('
  for l:i in range(a:0 - 1)
    let l:out .= a:000[l:i] . '\|'
  endfor
  let l:out .= a:000[-1] . '\)'
  return l:out
endfun

" Build regexp of precision suffix.
fun! s:Suffix(prefix) abort
  return '\%(' . a:prefix . s:sign . s:digits1 . '\)\?'
endfun

" Finalize building regexp of number.
fun! s:Bless(blessed) abort
  return '\c' . a:blessed . '\>'
endfun

" vim: et sw=2 sts=-1 tw=100 fdm=marker
