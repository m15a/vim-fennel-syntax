" Vim syntax file
" Language: Fennel
" Last Change: 2020-06-21
" Original Maintainer: Calvin Rose
" Maintainer: Mitsuhiro Nakamura <m.nacamura@gmail.com>
" URL: https://github.com/mnacamura/vim-fennel-syntax
" License: MIT

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" Any uncaught syntax is highlighted as error.
syn match fennelError /[^[:space:]\n]/

" Comments {{{1
syn region fennelComment start=/;/ end=/$/ contains=fennelCommentTodo,@Spell
syntax match fennelCommentTodo contained /\(FIXME\|XXX\|TODO\):\?/

" }}}

" Unquoted and quasiquoted data
syn cluster fennelData contains=@fennelSimpleData,@fennelCompoundData
syn cluster fennelDataQ contains=@fennelSimpleData,@fennelCompoundDataQ
syn cluster fennelDataQQ contains=@fennelSimpleData,@fennelCompoundDataQQ

" Simple data {{{1
syn cluster fennelSimpleData contains=fennelConstant,fennelSymbol,fennelKeyword,fennelBoolean,fennelNumber,fennelString

" Constant (nil) {{{2
syn keyword fennelConstant nil

" Symbol and keyword {{{2
let s:symcharnodig = '\!\$%\&\#\*\+\-./:<=>?A-Z^_a-z|\x80-\U10FFFF'
let s:symchar = '0-9' . s:symcharnodig
execute 'syn match fennelSymbol "\v<%([' . s:symcharnodig . '])%([' . s:symchar . '])*>"'
execute 'syn match fennelKeyword "\v<:%([' . s:symchar . '])*>"'
unlet s:symchar s:symcharnodig

" Boolean {{{2
syn keyword fennelBoolean true false

" Number {{{2
syn match fennelNumber "\v\c<[-+]?%(\d+|\.\d+|\d+\.\d*)%(e[-+]?\d+)?>"
syn match fennelNumber "\v\c<[-+]?0x%(\x+|\.\x+|\x+\.\x*)%(p[-+]?\d+)?>"
" NOTE: Fennel seems to accept fractional and postfix 'p' in hex number even if Lua version < 5.2.

" String {{{2
syntax region fennelString matchgroup=fennelDelimiter start=/"/ skip=/\\\\\|\\"/ end=/"/ contains=fennelStringEscape,@Spell
syntax match fennelStringEscape '\v\\%([abfnrtv'"\\]|x[[0-9a-fA-F]]\{2}|25[0-5]|2[0-4][0-9]|[0-1][0-9][0-9])' contained

" Compound data {{{1
syn cluster fennelCompoundData contains=fennelList,fennelArray,fennelTable,fennelQuote,fennelQuasiQuote
syn cluster fennelCompoundDataQ contains=fennelListQ,fennelArrayQ,fennelTableQ,fennelQuote,fennelQuasiQuote
syn cluster fennelCompoundDataQQ contains=fennelListQQ,fennelArrayQQ,fennelTableQQ,fennelQuote,fennelQuasiQuote

" TODO: hash function

" Unquoted list, array, and table {{{2
syn region fennelList matchgroup=fennelDelimiter start=/#\@<!(/ end=/)/ contains=fennelError,@fennelComments,@fennelData,@fennelExpressions
syn region fennelArray matchgroup=fennelDelimiter start=/#\@<!\[/ end=/]/ contains=fennelError,@fennelComments,@fennelData,@fennelExpressions
syn region fennelTable matchgroup=fennelDelimiter start=/#\@<!{/ end=/}/ contains=fennelError,@fennelComments,@fennelData,@fennelExpressions

" Apparently unquoted but quoted list, array, and table {{{2
syn region fennelListQ matchgroup=fennelDelimiter start=/#\@<!(/ end=/)/ contained contains=fennelError,@fennelComments,@fennelDataQ
syn region fennelArrayQ matchgroup=fennelDelimiter start=/#\@<!\[/ end=/]/ contained contains=fennelError,@fennelComments,@fennelDataQ
syn region fennelTableQ matchgroup=fennelDelimiter start=/#\@<!{/ end=/}/ contained contains=fennelError,@fennelComments,@fennelDataQ

" Apparently unquoted but quasiquoted list, array, and table {{{2
syn region fennelListQQ matchgroup=fennelDelimiter start=/#\@<!(/ end=/)/ contained contains=fennelError,@fennelComments,@fennelDataQQ,fennelUnquote
syn region fennelArrayQQ matchgroup=fennelDelimiter start=/#\@<!\[/ end=/]/ contained contains=fennelError,@fennelComments,@fennelDataQQ,fennelUnquote
syn region fennelTableQQ matchgroup=fennelDelimiter start=/#\@<!{/ end=/}/ contained contains=fennelError,@fennelComments,@fennelDataQQ,fennelUnquote

" Quoted simple data {{{2
syn match fennelQuote /'\ze[^[:space:]\n();'`,\\#\[\]{}]/ nextgroup=@fennelSimpleData

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
syn match fennelQuasiQuote /`\ze[^[:space:]\n();'`,\\#\[\]{}]/ nextgroup=@fennelSimpleData

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
syn cluster fennelExpressions contains=fennelSpecialForm,fennelLuaKeyword

" Special forms {{{2
syn keyword fennelSpecialForm #
syn keyword fennelSpecialForm %
syn keyword fennelSpecialForm *
syn keyword fennelSpecialForm +
syn keyword fennelSpecialForm -
syn keyword fennelSpecialForm ->
syn keyword fennelSpecialForm ->>
syn keyword fennelSpecialForm -?>
syn keyword fennelSpecialForm -?>>
syn keyword fennelSpecialForm .
syn keyword fennelSpecialForm ..
syn keyword fennelSpecialForm /
syn keyword fennelSpecialForm //
syn keyword fennelSpecialForm :
syn keyword fennelSpecialForm <
syn keyword fennelSpecialForm <=
syn keyword fennelSpecialForm =
syn keyword fennelSpecialForm >
syn keyword fennelSpecialForm >=
syn keyword fennelSpecialForm ^
syn keyword fennelSpecialForm and
syn keyword fennelSpecialForm comment
syn keyword fennelSpecialForm do
syn keyword fennelSpecialForm doc
syn keyword fennelSpecialForm doto
syn keyword fennelSpecialForm each
syn keyword fennelSpecialForm eval-compiler
syn keyword fennelSpecialForm fn
syn keyword fennelSpecialForm for
syn keyword fennelSpecialForm global
syn keyword fennelSpecialForm hashfn
syn keyword fennelSpecialForm if
syn keyword fennelSpecialForm include
syn keyword fennelSpecialForm lambda
syn keyword fennelSpecialForm length
syn keyword fennelSpecialForm let
syn keyword fennelSpecialForm local
syn keyword fennelSpecialForm lua
syn keyword fennelSpecialForm macro
syn keyword fennelSpecialForm macros
syn keyword fennelSpecialForm match
syn keyword fennelSpecialForm not
syn keyword fennelSpecialForm not=
syn keyword fennelSpecialForm or
syn keyword fennelSpecialForm partial
syn keyword fennelSpecialForm quote
syn keyword fennelSpecialForm require-macros
syn keyword fennelSpecialForm set
syn keyword fennelSpecialForm set-forcibly!
syn keyword fennelSpecialForm tset
syn keyword fennelSpecialForm values
syn keyword fennelSpecialForm var
syn keyword fennelSpecialForm when
syn keyword fennelSpecialForm while
syn keyword fennelSpecialForm ~=
syn keyword fennelSpecialForm λ

" Lua keywords {{{2
syntax keyword fennelLuaKeyword
      \ _G
      \ _VERSION
      \ assert
      \ collectgarbage
      \ dofile
      \ error
      \ getmetatable
      \ ipairs
      \ load
      \ loadfile
      \ next
      \ pairs
      \ pcall
      \ print
      \ rawequal
      \ rawget
      \ rawlen
      \ rawset
      \ require
      \ select
      \ setmetatable
      \ tonumber
      \ tostring
      \ type
      \ xpcall
      \ coroutine
      \ coroutine.create
      \ coroutine.isyieldable
      \ coroutine.resume
      \ coroutine.running
      \ coroutine.status
      \ coroutine.wrap
      \ coroutine.yield
      \ debug
      \ debug.debug
      \ debug.gethook
      \ debug.getinfo
      \ debug.getlocal
      \ debug.getmetatable
      \ debug.getregistry
      \ debug.getupvalue
      \ debug.getuservalue
      \ debug.sethook
      \ debug.setlocal
      \ debug.setmetatable
      \ debug.setupvalue
      \ debug.setuservalue
      \ debug.traceback
      \ debug.upvalueid
      \ debug.upvaluejoin
      \ io
      \ io.close
      \ io.flush
      \ io.input
      \ io.lines
      \ io.open
      \ io.output
      \ io.popen
      \ io.read
      \ io.stderr
      \ io.stdin
      \ io.stdout
      \ io.tmpfile
      \ io.type
      \ io.write
      \ math
      \ math.abs
      \ math.acos
      \ math.asin
      \ math.atan
      \ math.ceil
      \ math.cos
      \ math.deg
      \ math.exp
      \ math.floor
      \ math.fmod
      \ math.huge
      \ math.log
      \ math.max
      \ math.maxinteger
      \ math.min
      \ math.mininteger
      \ math.modf
      \ math.pi
      \ math.rad
      \ math.random
      \ math.randomseed
      \ math.sin
      \ math.sqrt
      \ math.tan
      \ math.tointeger
      \ math.type
      \ math.ult
      \ os
      \ os.clock
      \ os.date
      \ os.difftime
      \ os.execute
      \ os.exit
      \ os.getenv
      \ os.remove
      \ os.rename
      \ os.setlocale
      \ os.time
      \ os.tmpname
      \ package
      \ package.config
      \ package.cpath
      \ package.loaded
      \ package.loadlib
      \ package.path
      \ package.preload
      \ package.searchers
      \ package.searchpath
      \ string
      \ string.byte
      \ string.char
      \ string.dump
      \ string.find
      \ string.format
      \ string.gmatch
      \ string.gsub
      \ string.len
      \ string.lower
      \ string.match
      \ string.pack
      \ string.packsize
      \ string.rep
      \ string.reverse
      \ string.sub
      \ string.unpack
      \ string.upper
      \ table
      \ table.concat
      \ table.insert
      \ table.move
      \ table.pack
      \ table.remove
      \ table.sort
      \ table.unpack
      \ utf8
      \ utf8.char
      \ utf8.charpattern
      \ utf8.codepoint
      \ utf8.codes
      \ utf8.len
      \ utf8.offset

" Highlighting {{{1
syntax sync fromstart

hi def link fennelError Error
hi def link fennelDelimiter Delimiter
hi def link fennelComment Comment
hi def link fennelCommentTodo TODO
hi def link fennelConstant Constant
hi def link fennelSymbol Identifier
hi def link fennelKeyword String
hi def link fennelBoolean Boolean
hi def link fennelNumber Number
hi def link fennelString String
hi def link fennelStringEscape Character
hi def link fennelQuote fennelSpecialForm
hi def link fennelQuasiQuote fennelSpecialForm
hi def link fennelUnquote fennelSpecialForm
hi def link fennelSpecialForm Special
hi def link fennelLuaKeyword Function

" }}}

let b:current_syntax = "fennel"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: et sw=2 sts=-1 tw=100 fdm=marker
