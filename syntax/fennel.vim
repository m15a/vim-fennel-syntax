" Vim syntax file
" Language: Fennel
" Last Change: 2020-06-27
" Original Maintainer: Calvin Rose
" Maintainer: Mitsuhiro Nakamura <m.nacamura@gmail.com>
" URL: https://github.com/mnacamura/vim-fennel-syntax
" License: MIT

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

" Options {{{1

let s:use_lume = fennel#get('use_lume', 1)

" }}}

" Any uncaught syntax is highlighted as error.
syn match fennelError /[^[:space:]\n]/

" Comments {{{1
syn cluster fennelComments contains=fennelComment,fennelShebang
syn region fennelComment start=/;/ end=/$/ contains=fennelCommentTodo,@Spell
syn match fennelCommentTodo contained /\(FIXME\|XXX\|TODO\):\?/
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
syn match fennelSymbol /[^#:0-9[:space:]\n"'(),;@\[\]\\`{}~][^[:space:]\n"'(),;@\[\]\\`{}~]*/ contained
" <keyword> -> : <subsequent> +
" Keyword such as ::: is accepted by Fennel! 
syn match fennelKeyword /:[^[:space:]\n"'(),;@\[\]\\`{}~]\+/

" Boolean {{{2
syn keyword fennelBoolean true false

" Number {{{2
exec 'syn match fennelNumber /' . fennel#number#dec() . '/'
exec 'syn match fennelNumber /' . fennel#number#hex() . '/'
" NOTE: Fennel seems to accept fractional and postfix 'p' in hex number even if Lua version < 5.2.

" String {{{2
syn region fennelString matchgroup=fennelDelimiter start=/"/ skip=/\\\\\|\\"/ end=/"/ contains=@fennelEscapeChars,@Spell
syn cluster fennelEscapeChars contains=fennelEscapeLiteral,fennelEscapeMnemonic,fennelEscapeMnemonicZ,fennelEscapeCharCode
syn match fennelEscapeLiteral /\\[\\"']/ contained
syn match fennelEscapeMnemonic /\\[abfnrtv]/ contained
syn match fennelEscapeCharCode /\\\%(\%(\%([01]\)\?[0-9]\)\?[0-9]\|2[0-4][0-9]\|25[0-5]\)/ contained

" Lua 5.2-
syn match fennelEscapeMnemonicZ /\\z/ contained
syn match fennelEscapeCharCode '\\x[[:xdigit:]]\{2}' contained

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

" Auxiliary syntaxes {{{2
syn match fennelAuxSyntax /\$\([1-9]\|\.\.\.\)\?/
syn keyword fennelAuxSyntax ... _ &
" Pattern prefix which can be nil, used in `match` 
syn match fennelAuxSyntax /\<?\ze[^[:space:]\n"'(),;@\[\]\\`{}~]/ contained containedin=fennelIdentifier
" Special suffix for gensym in macro
syn match fennelAuxSyntax /[^[:space:]\n"'(),;@\[\]\\`{}~]\zs#\>/ contained containedin=fennelIdentifier

" Lua keywords {{{2
syn keyword fennelLuaKeyword _G _VERSION
syn keyword fennelLuaKeyword assert collectgarbage dofile error getmetatable ipairs load loadfile
syn keyword fennelLuaKeyword next pairs pcall print rawequal rawget rawlen rawset require select
syn keyword fennelLuaKeyword setmetatable tonumber tostring type xpcall unpack
syn keyword fennelLuaKeyword coroutine
syn keyword fennelLuaKeyword coroutine.create coroutine.isyieldable coroutine.resume
syn keyword fennelLuaKeyword coroutine.running coroutine.status coroutine.wrap coroutine.yield
syn keyword fennelLuaKeyword debug
syn keyword fennelLuaKeyword debug.debug debug.gethook debug.getinfo debug.getlocal
syn keyword fennelLuaKeyword debug.getmetatable debug.getregistry debug.getupvalue
syn keyword fennelLuaKeyword debug.getuservalue debug.sethook debug.setlocal debug.setmetatable
syn keyword fennelLuaKeyword debug.setupvalue debug.setuservalue debug.traceback debug.upvalueid
syn keyword fennelLuaKeyword debug.upvaluejoin
syn keyword fennelLuaKeyword io
syn keyword fennelLuaKeyword io.close io.flush io.input io.lines io.open io.output io.popen
syn keyword fennelLuaKeyword io.read io.stderr io.stdin io.stdout io.tmpfile io.type io.write
syn keyword fennelLuaKeyword math
syn keyword fennelLuaKeyword math.abs math.acos math.asin math.atan math.ceil math.cos math.deg
syn keyword fennelLuaKeyword math.exp math.floor math.fmod math.huge math.log math.max
syn keyword fennelLuaKeyword math.maxinteger math.min math.mininteger math.modf math.pi math.rad
syn keyword fennelLuaKeyword math.random math.randomseed math.sin math.sqrt math.tan
syn keyword fennelLuaKeyword math.tointeger math.type math.ult
syn keyword fennelLuaKeyword os
syn keyword fennelLuaKeyword os.clock os.date os.difftime os.execute os.exit os.getenv os.remove
syn keyword fennelLuaKeyword os.rename os.setlocale os.time os.tmpname
syn keyword fennelLuaKeyword package
syn keyword fennelLuaKeyword package.config package.cpath package.loaded package.loadlib
syn keyword fennelLuaKeyword package.path package.preload package.searchers package.searchpath
syn keyword fennelLuaKeyword string
syn keyword fennelLuaKeyword string.byte string.char string.dump string.find string.format
syn keyword fennelLuaKeyword string.gmatch string.gsub string.len string.lower string.match
syn keyword fennelLuaKeyword string.pack string.packsize string.rep string.reverse string.sub
syn keyword fennelLuaKeyword string.unpack string.upper
syn keyword fennelLuaKeyword table
syn keyword fennelLuaKeyword table.concat table.insert table.move table.pack table.remove
syn keyword fennelLuaKeyword table.sort table.unpack
syn keyword fennelLuaKeyword utf8
syn keyword fennelLuaKeyword utf8.char utf8.charpattern utf8.codepoint utf8.codes utf8.len
syn keyword fennelLuaKeyword utf8.offset

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
hi def link fennelSymbol Identifier
hi def link fennelKeyword Identifier
hi def link fennelBoolean Boolean
hi def link fennelNumber Number
hi def link fennelString String
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

let b:current_syntax = "fennel"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: et sw=2 sts=-1 tw=100 fdm=marker
