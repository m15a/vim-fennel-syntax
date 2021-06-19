" Vim syntax file
" Language: Fennel
" Last Change: 2021-06-19
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

let s:lua_version = fennel#Get('lua_version', '5.1')
let s:use_lume = fennel#Get('use_lume', 1)

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
" where <initial> -> [^#:0-9[:space:]\n"'(),;@\[\]\\`{}~]
"       <subsequent> ->   [^[:space:]\n"'(),;@\[\]\\`{}~]
syn match fennelIdentifier /[^#:0-9[:space:]\n"'(),;@\[\]\\`{}~][^[:space:]\n"'(),;@\[\]\\`{}~]*/
syn match fennelLuaTableItemAccessor /\./ contained containedin=fennelIdentifier
syn match fennelLuaMethodCall /:/ contained containedin=fennelIdentifier
syn match fennelSymbol /[^#:0-9[:space:]\n"'(),;@\[\]\\`{}~][^[:space:]\n"'(),;@\[\]\\`{}~]*/ contained
" <keyword> -> : <subsequent> +
" Keyword such as ::: is accepted by Fennel! 
syn match fennelKeyword /:[^[:space:]\n"'(),;@\[\]\\`{}~]\+/

" Boolean {{{2
syn keyword fennelBoolean true false

" Number {{{2
exec 'syn match fennelNumber /' . fennel#number#Dec() . '/'
exec 'syn match fennelNumber /' . fennel#number#Hex() . '/'
" NOTE: Fennel seems to accept fractional and postfix 'p' in hex number even if Lua version < 5.2.

" String {{{2
syn region fennelString matchgroup=fennelStringDelimiter start=/"/ skip=/\\\\\|\\"/ end=/"/ contains=@fennelEscapeChars,@Spell
syn cluster fennelEscapeChars contains=fennelEscapeLiteral,fennelEscapeMnemonic,fennelEscapeMnemonicZ,fennelEscapeCharCode
syn match fennelEscapeLiteral /\\[\\"']/ contained
syn match fennelEscapeMnemonic /\\[abfnrtv]/ contained
syn match fennelEscapeCharCode /\\\%(\%(\%([01]\)\?[0-9]\)\?[0-9]\|2[0-4][0-9]\|25[0-5]\)/ contained

" Lua 5.2-
syn match fennelEscapeMnemonicZ /\\z/ contained
syn match fennelEscapeCharCode '\\x[[:xdigit:]]\{2}' contained

" Lua 5.3-
syn match fennelEscapeCharCode '\\u{[[:xdigit:]]\+}' contained

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
syn keyword fennelSpecialForm and comment do doc doto each eval-compiler fn for global hashfn if
syn keyword fennelSpecialForm include lambda length let local lua macro macros match not not= or
syn keyword fennelSpecialForm partial quote require-macros set set-forcibly! tset values var when
syn keyword fennelSpecialForm while ~= λ
" Compiler environment
" TODO: Would be better to highlight these items only inside compiler environment
syn keyword fennelSpecialForm list sym list? sym? table? sequence? gensym varg? multi-sym? view assert-compile
syn keyword fennelSpecialForm in-scope? macroexpand
" 0.4.0
syn keyword fennelSpecialForm import-macros rshift lshift bor band bnot and bxor pick-values pick-args
" 0.4.2
syn keyword fennelSpecialForm with-open
" 0.8.0
syn keyword fennelSpecialForm collect icollect

" Auxiliary syntaxes {{{2
syn match fennelAuxSyntax /\$\([1-9]\|\.\.\.\)\?/
syn keyword fennelAuxSyntax ... _ &
syn keyword fennelAuxSyntax &as
" Pattern prefix `?foo` or guard syntax `(matched ? (pred matched)` used in `match` 
syn match fennelAuxSyntax /\<?\ze\([^[:space:]\n"'(),;@\[\]\\`{}~]\|\>\)/ contained containedin=fennelIdentifier
" Special suffix for gensym in macro
syn match fennelAuxSyntax /[^[:space:]\n"'(),;@\[\]\\`{}~]\zs#\>/ contained containedin=fennelIdentifier
" TODO: Would be better to highlight `where` and `or` only inside `match` macro
syn keyword fennelAuxSyntax where

" Lua keywords {{{2
syn keyword fennelLuaKeyword _G
syn keyword fennelLuaKeyword _VERSION
syn keyword fennelLuaKeyword assert
syn keyword fennelLuaKeyword collectgarbage
syn keyword fennelLuaKeyword coroutine.create
syn keyword fennelLuaKeyword coroutine.resume
syn keyword fennelLuaKeyword coroutine.running
syn keyword fennelLuaKeyword coroutine.status
syn keyword fennelLuaKeyword coroutine.wrap
syn keyword fennelLuaKeyword coroutine.yield
syn keyword fennelLuaKeyword debug.debug
syn keyword fennelLuaKeyword debug.gethook
syn keyword fennelLuaKeyword debug.getinfo
syn keyword fennelLuaKeyword debug.getlocal
syn keyword fennelLuaKeyword debug.getmetatable
syn keyword fennelLuaKeyword debug.getregistry
syn keyword fennelLuaKeyword debug.getupvalue
syn keyword fennelLuaKeyword debug.sethook
syn keyword fennelLuaKeyword debug.setlocal
syn keyword fennelLuaKeyword debug.setmetatable
syn keyword fennelLuaKeyword debug.setupvalue
syn keyword fennelLuaKeyword debug.traceback
syn keyword fennelLuaKeyword dofile
syn keyword fennelLuaKeyword error
syn keyword fennelLuaKeyword file:close
syn keyword fennelLuaKeyword file:flush
syn keyword fennelLuaKeyword file:lines
syn keyword fennelLuaKeyword file:read
syn keyword fennelLuaKeyword file:seek
syn keyword fennelLuaKeyword file:setvbuf
syn keyword fennelLuaKeyword file:write
syn keyword fennelLuaKeyword getmetatable
syn keyword fennelLuaKeyword io.close
syn keyword fennelLuaKeyword io.flush
syn keyword fennelLuaKeyword io.input
syn keyword fennelLuaKeyword io.lines
syn keyword fennelLuaKeyword io.open
syn keyword fennelLuaKeyword io.output
syn keyword fennelLuaKeyword io.popen
syn keyword fennelLuaKeyword io.read
syn keyword fennelLuaKeyword io.stderr
syn keyword fennelLuaKeyword io.stdin
syn keyword fennelLuaKeyword io.stdout
syn keyword fennelLuaKeyword io.tmpfile
syn keyword fennelLuaKeyword io.type
syn keyword fennelLuaKeyword io.write
syn keyword fennelLuaKeyword ipairs
syn keyword fennelLuaKeyword load
syn keyword fennelLuaKeyword loadfile
syn keyword fennelLuaKeyword math.abs
syn keyword fennelLuaKeyword math.acos
syn keyword fennelLuaKeyword math.asin
syn keyword fennelLuaKeyword math.atan
syn keyword fennelLuaKeyword math.ceil
syn keyword fennelLuaKeyword math.cos
syn keyword fennelLuaKeyword math.deg
syn keyword fennelLuaKeyword math.exp
syn keyword fennelLuaKeyword math.floor
syn keyword fennelLuaKeyword math.fmod
syn keyword fennelLuaKeyword math.huge
syn keyword fennelLuaKeyword math.log
syn keyword fennelLuaKeyword math.max
syn keyword fennelLuaKeyword math.min
syn keyword fennelLuaKeyword math.modf
syn keyword fennelLuaKeyword math.pi
syn keyword fennelLuaKeyword math.rad
syn keyword fennelLuaKeyword math.random
syn keyword fennelLuaKeyword math.randomseed
syn keyword fennelLuaKeyword math.sin
syn keyword fennelLuaKeyword math.sqrt
syn keyword fennelLuaKeyword math.tan
syn keyword fennelLuaKeyword next
syn keyword fennelLuaKeyword os.clock
syn keyword fennelLuaKeyword os.date
syn keyword fennelLuaKeyword os.difftime
syn keyword fennelLuaKeyword os.execute
syn keyword fennelLuaKeyword os.exit
syn keyword fennelLuaKeyword os.getenv
syn keyword fennelLuaKeyword os.remove
syn keyword fennelLuaKeyword os.rename
syn keyword fennelLuaKeyword os.setlocale
syn keyword fennelLuaKeyword os.time
syn keyword fennelLuaKeyword os.tmpname
syn keyword fennelLuaKeyword package.cpath
syn keyword fennelLuaKeyword package.loaded
syn keyword fennelLuaKeyword package.loadlib
syn keyword fennelLuaKeyword package.path
syn keyword fennelLuaKeyword package.preload
syn keyword fennelLuaKeyword pairs
syn keyword fennelLuaKeyword pcall
syn keyword fennelLuaKeyword print
syn keyword fennelLuaKeyword rawequal
syn keyword fennelLuaKeyword rawget
syn keyword fennelLuaKeyword rawset
syn keyword fennelLuaKeyword require
syn keyword fennelLuaKeyword select
syn keyword fennelLuaKeyword setmetatable
syn keyword fennelLuaKeyword string.byte
syn keyword fennelLuaKeyword string.char
syn keyword fennelLuaKeyword string.dump
syn keyword fennelLuaKeyword string.find
syn keyword fennelLuaKeyword string.format
syn keyword fennelLuaKeyword string.gmatch
syn keyword fennelLuaKeyword string.gsub
syn keyword fennelLuaKeyword string.len
syn keyword fennelLuaKeyword string.lower
syn keyword fennelLuaKeyword string.match
syn keyword fennelLuaKeyword string.rep
syn keyword fennelLuaKeyword string.reverse
syn keyword fennelLuaKeyword string.sub
syn keyword fennelLuaKeyword string.upper
syn keyword fennelLuaKeyword table.concat
syn keyword fennelLuaKeyword table.insert
syn keyword fennelLuaKeyword table.remove
syn keyword fennelLuaKeyword table.sort
syn keyword fennelLuaKeyword tonumber
syn keyword fennelLuaKeyword tostring
syn keyword fennelLuaKeyword type
syn keyword fennelLuaKeyword xpcall
if match(s:lua_version, '^5\.[234]$') > -1
  syn keyword fennelLuaKeyword debug.getuservalue
  syn keyword fennelLuaKeyword debug.setuservalue
  syn keyword fennelLuaKeyword debug.upvalueid
  syn keyword fennelLuaKeyword debug.upvaluejoin
  syn keyword fennelLuaKeyword package.config
  syn keyword fennelLuaKeyword package.searchers
  syn keyword fennelLuaKeyword package.searchpath
  syn keyword fennelLuaKeyword rawlen
  syn keyword fennelLuaKeyword table.pack
  syn keyword fennelLuaKeyword table.unpack
endif
if match(s:lua_version, '^5\.[12]$') > -1
  syn keyword fennelLuaKeyword math.atan2
  syn keyword fennelLuaKeyword math.cosh
  syn keyword fennelLuaKeyword math.frexp
  syn keyword fennelLuaKeyword math.ldexp
  syn keyword fennelLuaKeyword math.pow
  syn keyword fennelLuaKeyword math.sinh
  syn keyword fennelLuaKeyword math.tanh
endif
if match(s:lua_version, '^5\.[34]$') > -1
  syn keyword fennelLuaKeyword coroutine.isyieldable
  syn keyword fennelLuaKeyword math.maxinteger
  syn keyword fennelLuaKeyword math.mininteger
  syn keyword fennelLuaKeyword math.tointeger
  syn keyword fennelLuaKeyword math.type
  syn keyword fennelLuaKeyword math.ult
  syn keyword fennelLuaKeyword string.pack
  syn keyword fennelLuaKeyword string.packsize
  syn keyword fennelLuaKeyword string.unpack
  syn keyword fennelLuaKeyword table.move
  syn keyword fennelLuaKeyword utf8.char
  syn keyword fennelLuaKeyword utf8.charpattern
  syn keyword fennelLuaKeyword utf8.codepoint
  syn keyword fennelLuaKeyword utf8.codes
  syn keyword fennelLuaKeyword utf8.len
  syn keyword fennelLuaKeyword utf8.offset
endif
if match(s:lua_version, '^5\.1$') > -1
  syn keyword fennelLuaKeyword debug.getfenv
  syn keyword fennelLuaKeyword debug.setfenv
  syn keyword fennelLuaKeyword getfenv
  syn keyword fennelLuaKeyword loadstring
  syn keyword fennelLuaKeyword math.log10
  syn keyword fennelLuaKeyword module
  syn keyword fennelLuaKeyword package.loaders
  syn keyword fennelLuaKeyword package.seeall
  syn keyword fennelLuaKeyword setfenv
  syn keyword fennelLuaKeyword table.maxn
  syn keyword fennelLuaKeyword unpack
endif
if match(s:lua_version, '^5\.2$') > -1
  syn keyword fennelLuaKeyword bit32.arshift
  syn keyword fennelLuaKeyword bit32.band
  syn keyword fennelLuaKeyword bit32.bnot
  syn keyword fennelLuaKeyword bit32.bor
  syn keyword fennelLuaKeyword bit32.btest
  syn keyword fennelLuaKeyword bit32.bxor
  syn keyword fennelLuaKeyword bit32.extract
  syn keyword fennelLuaKeyword bit32.lrotate
  syn keyword fennelLuaKeyword bit32.lshift
  syn keyword fennelLuaKeyword bit32.replace
  syn keyword fennelLuaKeyword bit32.rrotate
  syn keyword fennelLuaKeyword bit32.rshift
endif
if match(s:lua_version, '^5\.4$') > -1
  syn keyword fennelLuaKeyword coroutine.close
  syn keyword fennelLuaKeyword warn
endif

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
hi def link fennelEscapeLiteral Character
hi def link fennelEscapeMnemonic Character
hi def link fennelEscapeMnemonicZ fennelComment
hi def link fennelEscapeCharCode Character
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
