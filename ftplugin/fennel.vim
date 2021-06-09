" Vim filetype plugin file
" Language: Fennel
" Last Change: 2021-06-10
" Original Maintainer: Calvin Rose
" Maintainer: Mitsuhiro Nakamura <m.nacamura@gmail.com>
" URL: https://github.com/mnacamura/vim-fennel-syntax
" License: MIT

if exists("b:did_ftplugin")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

setl iskeyword=@,33,35-38,42-43,45-58,60-63,94-95,124
" 32: SPACE
" 34: "
" 39: '
" 40,41: ()
" 44: ,
" 58: :
" NOTE: `:` is not permitted in identifiers but...
"   1. required to highlight special form `:`,
"   2. required to highlight method call `(obj:method ...)`, and
"   3. convenient when for example searching a keyword by `*`.
" 59: ;
" 64: @
" 65-90: A-Z (included in @)
" 91,93: []
" 92: \
" 96: `
" 97-122: a-z (included in @)
" 123,125: {}
" 126: ~
" 127: DEL

" There will be false positives, but this is better than missing the whole set
" of user-defined def* definitions.
setl define=\\v[(/]def(ault)@!\\S*

setl comments=n:;
setl commentstring=;\ %s

setl lisp
setl lispwords=fn,lambda,let,match,when,each,for,while,doto,macro
setl lispwords+=λ
setl lispwords+=with-open,collect,icollect

if &omnifunc == ''
  setl omnifunc=syntaxcomplete#Complete
endif

let b:undo_ftplugin = 'setl isk< def< com< cms< lisp< lw< ofu<'

let b:did_ftplugin = 1

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: et sw=2 sts=-1 tw=100 fdm=marker
