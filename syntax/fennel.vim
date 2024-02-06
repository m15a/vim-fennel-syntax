" Vim syntax file
" Language: Fennel
" Last Change: 2024-02-06
" Original Maintainer: Calvin Rose
" Maintainer: Mitsuhiro Nakamura <m.nacamura@gmail.com>
" URL: https://github.com/mnacamura/vim-fennel-syntax
" License: MIT

if exists('b:burrent_byntax')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" Options {{{1

let s:lua_version = fennel#GetOption('lua_version', fennel#GetLuaVersion())
let s:use_luajit = fennel#GetOption('use_luajit', fennel#LuaIsLuajit())
let s:use_lume = fennel#GetOption('use_lume', 1)

" }}}

" Any uncaught syntax is highlighted as error.
syn match fennelError /[^[:space:]\n]/

" Comments {{{1
syn cluster fennelComments contains=fennelComment,fennelShebang
syn region fennelComment start=/;/ end=/$/ contains=fennelCommentTodo,@Spell
syn match fennelCommentTodo contained /\(FIXME\|XXX\|TODO\|NOTE\|TBD\):\?/
syn match fennelShebang /\%^#![\/ ].*$/

" }}}

" Unquoted and quasiquoted data
syn cluster fennelData contains=fennelIdentifier,@fennelSimpleData,@fennelCompoundData
syn cluster fennelDataQ contains=fennelSymbol,@fennelSimpleData,@fennelCompoundDataQ
syn cluster fennelDataQQ contains=fennelSymbol,@fennelSimpleData,@fennelCompoundDataQQ

" Simple data {{{1
syn cluster fennelSimpleData contains=fennelConstant,fennelKeyword,fennelBoolean,fennelNumber,fennelString

" Constant (nil) {{{2
syn keyword fennelConstant nil

" Identifier, symbol, and keyword {{{2
"
" <identifier> -> <initial> <subsequent> *
" where <initial> -> [^#&:0-9[:space:]\n"'(),;@\[\]\\`{}~]
"       <subsequent> ->   [^&[:space:]\n"'(),;@\[\]\\`{}~]
syn match fennelIdentifier /[^#&:0-9[:space:]\n"'(),;@\[\]\\`{}~][^&[:space:]\n"'(),;@\[\]\\`{}~]*/
syn match fennelLuaTableItemAccessor /\./ contained containedin=fennelIdentifier
syn match fennelLuaMethodCall /:/ contained containedin=fennelIdentifier
syn match fennelSymbol /[^#&:0-9[:space:]\n"'(),;@\[\]\\`{}~][^&[:space:]\n"'(),;@\[\]\\`{}~]*/ contained
" <keyword> -> : <subsequent> +
" Keyword such as ::: is accepted by Fennel! 
syn match fennelKeyword /:[^[:space:]\n"'(),;@\[\]\\`{}~]\+/

" Boolean {{{2
syn keyword fennelBoolean true false

" Number {{{2
exe 'syn match fennelNumber /' . fennel#number#Dec() . '/'
if s:use_luajit || s:lua_version >=# '5.2'
  exe 'syn match fennelNumber /' . fennel#number#Hex() . '/'
else
  exe 'syn match fennelNumber /' . fennel#number#HexInt() . '/'
endif

" String {{{2
syn region fennelString matchgroup=fennelStringDelimiter start=/"/ skip=/\\\\\|\\"/ end=/"/ contains=@fennelEscapeChars,@Spell
syn cluster fennelEscapeChars contains=fennelEscapeChar,fennelEscapeMnemonic,fennelEscapeMnemonicZ,fennelEscapeMnemonicZError,fennelEscapeCharCode,fennelEscapeCharCodeError
syn match fennelEscapeChar /\\[\\"'\n]/ contained
syn match fennelEscapeMnemonic /\\[abfnrtv]/ contained
syn match fennelEscapeCharCode /\\\%(25[0-5]\|2[0-4][0-9]\|\%(\%([01]\)\?[0-9]\)\?[0-9]\)/ contained
if s:use_luajit || s:lua_version >=# '5.2'
  syn match fennelEscapeMnemonicZ /\\z/ contained
  syn match fennelEscapeCharCode '\\x[[:xdigit:]]\{2}' contained
else
  syn match fennelEscapeMnemonicZError /\\z/ contained
  syn match fennelEscapeCharCodeError '\\x[[:xdigit:]]\{2}' contained
endif
if s:lua_version >=# '5.3'
  syn match fennelEscapeCharCode '\\u{[[:xdigit:]]\+}' contained
else
  syn match fennelEscapeCharCodeError '\\u{[[:xdigit:]]\+}' contained
endif

" Compound data {{{1
syn cluster fennelCompoundData contains=fennelList,fennelArray,fennelTable,fennelQuote,fennelQuasiQuote
syn cluster fennelCompoundDataQ contains=fennelListQ,fennelArrayQ,fennelTableQ,fennelQuote,fennelQuasiQuote
syn cluster fennelCompoundDataQQ contains=fennelListQQ,fennelArrayQQ,fennelTableQQ,fennelQuote,fennelQuasiQuote

" TODO: hash function as compound data
" It would be better if $ and $1-$9 are only highlighted in hashfn.

" Unquoted list, array, and table {{{2
syn region fennelList matchgroup=fennelDelimiter start=/(/ end=/)/ contains=fennelError,@fennelComments,@fennelData,@fennelExpressions
syn region fennelArray matchgroup=fennelDelimiter start=/\[/ end=/]/ contains=fennelError,@fennelComments,@fennelData,@fennelExpressions
syn region fennelTable matchgroup=fennelDelimiter start=/{/ end=/}/ contains=fennelError,@fennelComments,@fennelData,@fennelExpressions

" Apparently unquoted but quoted list, array, and table {{{2
syn region fennelListQ matchgroup=fennelDelimiter start=/(/ end=/)/ contained contains=fennelError,@fennelComments,@fennelDataQ
syn region fennelArrayQ matchgroup=fennelDelimiter start=/\[/ end=/]/ contained contains=fennelError,@fennelComments,@fennelDataQ
syn region fennelTableQ matchgroup=fennelDelimiter start=/{/ end=/}/ contained contains=fennelError,@fennelComments,@fennelDataQ

" Apparently unquoted but quasiquoted list, array, and table {{{2
syn region fennelListQQ matchgroup=fennelDelimiter start=/(/ end=/)/ contained contains=fennelError,@fennelComments,@fennelDataQQ,fennelUnquote
syn region fennelArrayQQ matchgroup=fennelDelimiter start=/\[/ end=/]/ contained contains=fennelError,@fennelComments,@fennelDataQQ,fennelUnquote
syn region fennelTableQQ matchgroup=fennelDelimiter start=/{/ end=/}/ contained contains=fennelError,@fennelComments,@fennelDataQQ,fennelUnquote

" Quoted simple data {{{2
syn match fennelQuote /'\ze[^[:space:]\n();'`,\\#\[\]{}]/ nextgroup=fennelSymbol,@fennelSimpleData

" Quoted list, array, and table {{{2
syn match fennelQuote /'\ze(/ nextgroup=fennelQuoteList
syn region fennelQuoteList matchgroup=fennelDelimiter start=/(/ end=/)/ contained contains=fennelError,@fennelComments,@fennelDataQ
syn match fennelQuote /'\ze\[/ nextgroup=fennelQuoteArray
syn region fennelQuoteArray matchgroup=fennelDelimiter start=/\[/ end=/]/ contained contains=fennelError,@fennelComments,@fennelDataQ
syn match fennelQuote /'\ze{/ nextgroup=fennelQuoteTable
syn region fennelQuoteTable matchgroup=fennelDelimiter start=/{/ end=/}/ contained contains=fennelError,@fennelComments,@fennelDataQ

" Quoted (un)quotes {{{2
syn match fennelQuote /'\ze'/ nextgroup=fennelQuote
syn match fennelQuote /'\ze`/ nextgroup=fennelQuasiQuote
syn match fennelQuote /'\ze,/ nextgroup=fennelUnquote

" Quasiquoted simple data {{{2
syn match fennelQuasiQuote /`\ze[^[:space:]\n();'`,\\#\[\]{}]/ nextgroup=fennelSymbol,@fennelSimpleData

" Quasiquoted list, array, and table {{{2
syn match fennelQuasiQuote /`\ze(/ nextgroup=fennelQuasiQuoteList
syn region fennelQuasiQuoteList matchgroup=fennelDelimiter start=/(/ end=/)/ contained contains=fennelError,@fennelComments,@fennelDataQQ,fennelUnquote
syn match fennelQuasiQuote /`\ze\[/ nextgroup=fennelQuasiQuoteArray
syn region fennelQuasiQuoteArray matchgroup=fennelDelimiter start=/\[/ end=/]/ contained contains=fennelError,@fennelComments,@fennelDataQQ,fennelUnquote
syn match fennelQuasiQuote /`\ze{/ nextgroup=fennelQuasiQuoteTable
syn region fennelQuasiQuoteTable matchgroup=fennelDelimiter start=/{/ end=/}/ contained contains=fennelError,@fennelComments,@fennelDataQQ,fennelUnquote

" Quasiquoted (un)quotes {{{2
syn match fennelQuasiQuote /`\ze'/ nextgroup=fennelQuote
syn match fennelQuasiQuote /`\ze`/ nextgroup=fennelQuasiQuote
syn match fennelQuasiQuote /`\ze,/ nextgroup=fennelUnquote

" Unquote {{{2
" Unlike Scheme, Fennel's unquote rejects spaces after ','.
syn match fennelUnquote /,\ze[^[:space:]\n]/ contained nextgroup=@fennelData,@fennelExpressions

" Expressions {{{1
syn cluster fennelExpressions contains=fennelSpecialForm,fennelAuxSyntax,fennelLuaKeyword

" Special forms {{{2
syn match fennelSpecialForm /\%^\@<!#\ze[^[:space:]\n);@\]\\}~]/
syn keyword fennelSpecialForm % * + - -> ->> -?> -?>> . .. / // : < <= = > >= ^
syn keyword fennelSpecialForm and comment do doto each eval-compiler fn for hashfn if
syn keyword fennelSpecialForm include lambda length let local lua macro macros match not not= or
syn keyword fennelSpecialForm partial quote set set-forcibly! tset values var when
syn keyword fennelSpecialForm while ~= λ
" Compiler environment
" TODO: Would be better to highlight these items only inside compiler environment
syn keyword fennelSpecialForm list sym list? sym? table? sequence? gensym varg? multi-sym? view assert-compile
syn keyword fennelSpecialForm in-scope? macroexpand
" 0.4.0
syn keyword fennelSpecialForm import-macros rshift lshift bor band bnot and bxor pick-values
" 0.4.2
syn keyword fennelSpecialForm with-open
" 0.8.0
syn keyword fennelSpecialForm collect icollect
" 0.10.0
syn keyword fennelSpecialForm accumulate
" 1.1.0
syn keyword fennelSpecialForm match-try
" 1.2.0
syn keyword fennelSpecialForm fcollect
" 1.3.0
syn keyword fennelSpecialForm case case-try faccumulate
" 1.4.0
syn keyword fennelSpecialForm tail! assert-repl

" Auxiliary syntaxes {{{2
syn match fennelAuxSyntax /\$\([1-9]\|\.\.\.\)\?/
syn keyword fennelAuxSyntax ... _ &
syn keyword fennelAuxSyntax &as
syn keyword fennelAuxSyntax &into &until
" Pattern prefix `?foo` or guard syntax `(matched ? (pred matched)` used in `match` 
syn match fennelAuxSyntax /\<?\ze\([^[:space:]\n"'(),;@\[\]\\`{}~]\|\>\)/ contained containedin=fennelIdentifier
" Special suffix for gensym in macro
syn match fennelAuxSyntax /[^[:space:]\n"'(),;@\[\]\\`{}~]\zs#\>/ contained containedin=fennelIdentifier
" TODO: Would be better to highlight `where` and `or` only inside `match` macro
syn keyword fennelAuxSyntax where

" Lua keywords {{{2

let b:did_fennel_syntax = 1
runtime! syntax/fennel-lua.vim
runtime! syntax/fennel-luajit.vim
unlet b:did_fennel_syntax

" Lume keywords {{{2
if s:use_lume
  syn keyword fennelLuaKeyword lume
  syn keyword fennelLuaKeyword lume.clamp lume.round lume.sign lume.lerp lume.smooth lume.pingpong
  syn keyword fennelLuaKeyword lume.distance lume.angle lume.vector lume.random lume.randomchoice
  syn keyword fennelLuaKeyword lume.weightedchoice lume.isarray lume.push lume.remove lume.clear
  syn keyword fennelLuaKeyword lume.extend lume.shuffle lume.sort lume.array lume.each lume.map
  syn keyword fennelLuaKeyword lume.all lume.any lume.reduce lume.unique lume.filter lume.reject
  syn keyword fennelLuaKeyword lume.merge lume.concat lume.find lume.match lume.count lume.slice
  syn keyword fennelLuaKeyword lume.first lume.last lume.invert lume.keys lume.clone lume.fn
  syn keyword fennelLuaKeyword lume.once lume.memoize lume.combine lume.call lume.time lume.lambda
  syn keyword fennelLuaKeyword lume.serialize lume.deserialize lume.split lume.trim lume.wordwrap
  syn keyword fennelLuaKeyword lume.format lume.trace lume.dostring lume.uuid lume.hotswap
  syn keyword fennelLuaKeyword lume.ripairs lume.color lume.chain
endif

" Highlighting {{{1
syn sync fromstart

hi def link fennelError Error
hi def link fennelDelimiter Delimiter
hi def link fennelComment Comment
hi def link fennelCommentTodo TODO
hi def link fennelShebang Comment
hi def link fennelConstant Constant
" hi def link fennelIdentifier Normal
hi def link fennelLuaTableItemAccessor Delimiter
hi def link fennelLuaMethodCall Delimiter
hi def link fennelSymbol Identifier
hi def link fennelKeyword Identifier
hi def link fennelBoolean Boolean
hi def link fennelNumber Number
hi def link fennelString String
hi def link fennelStringDelimiter fennelDelimiter
hi def link fennelEscapeChar Character
hi def link fennelEscapeMnemonic Character
hi def link fennelEscapeMnemonicZ fennelComment
hi def link fennelEscapeMnemonicZError fennelError
hi def link fennelEscapeCharCode Character
hi def link fennelEscapeCharCodeError fennelError
hi def link fennelQuote fennelSpecialForm
hi def link fennelQuasiQuote fennelSpecialForm
hi def link fennelUnquote fennelAuxSyntax
hi def link fennelSpecialForm Statement
hi def link fennelAuxSyntax Special
hi def link fennelLuaKeyword Function

" }}}

let b:current_syntax = 'fennel'

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: et sw=2 sts=-1 tw=100 fdm=marker
