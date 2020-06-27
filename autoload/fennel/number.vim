" Helper functions for fennel-syntax plugin
" Last Change: 2020-06-27
" Author: Mitsuhiro Nakamura <m.nacamura@gmail.com>
" URL: https://github.com/mnacamura/vim-fennel-syntax
" License: MIT

" Build regexp of decimal number
fun! fennel#number#dec() abort
  let l:body = s:or(s:digits1, '\.' . s:digits1, s:digits1 . '\.' . s:digits0)
  return s:bless(s:sign . l:body . s:suffix('e'))
endfun

" Build regexp of hex number
fun! fennel#number#hex() abort
  let l:prefix = '_*0_*x'
  let l:body = s:or(s:xdigits1, '\.' . s:xdigits1, s:xdigits1 . '\.' . s:xdigits0)
  return s:bless(s:sign . l:prefix . l:body . s:suffix('p'))
endfun

let s:sign = '_*[-+]\?'

let s:digits0 = '[_[:digit:]]*'

let s:xdigits0 = '[_[:xdigit:]]*'

let s:digits1 = s:digits0 . '[[:digit:]]' . s:digits0

let s:xdigits1 = s:xdigits0 . '[[:xdigit:]]' . s:xdigits0

" Enclose items in '%( ... | ... )'
fun! s:or(...) abort
  let l:out = '\%('
  for l:i in range(a:0 - 1)
    let l:out .= a:000[l:i] . '\|'
  endfor
  let l:out .= a:000[-1] . '\)'
  return l:out
endfun

" Build regexp of precision suffix
fun! s:suffix(prefix) abort
  return '\%(' . a:prefix . s:sign . s:digits1 . '\)\?'
endfun

" Finalize building regexp of number
fun! s:bless(blessed) abort
  return '\c' . a:blessed . '\>'
endfun
