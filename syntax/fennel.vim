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

syntax keyword fennelCommentTodo contained FIXME XXX TODO FIXME: XXX: TODO:

" Fennel comments
syn match fennelComment ";.*$" contains=fennelCommentTodo,@Spell

syntax match fennelStringEscape '\v\\%([abfnrtv'"\\]|x[[0-9a-fA-F]]\{2}|25[0-5]|2[0-4][0-9]|[0-1][0-9][0-9])' contained
syntax region fennelString matchgroup=fennelStringDelimiter start=/"/ skip=/\\\\\|\\"/ end=/"/ contains=fennelStringEscape,@Spell
syntax region fennelString matchgroup=fennelStringDelimiter start=/'/ skip=/\\\\\|\\'/ end=/'/ contains=fennelStringEscape,@Spell

syn keyword fennelConstant nil

syn keyword fennelBoolean true
syn keyword fennelBoolean false

" Fennel special forms
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

" Lua keywords
syntax keyword LuaSpecialValue
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

" Fennel Symbols
let s:symcharnodig = '\!\$%\&\#\*\+\-./:<=>?A-Z^_a-z|\x80-\U10FFFF'
let s:symchar = '0-9' . s:symcharnodig
execute 'syn match fennelSymbol "\v<%([' . s:symcharnodig . '])%([' . s:symchar . '])*>"'
execute 'syn match fennelKeyword "\v<:%([' . s:symchar . '])*>"'
unlet! s:symchar s:symcharnodig

syn match fennelQuote "`"
syn match fennelQuote "@"

" Fennel numbers
syntax match fennelNumber "\v\c<[-+]?\d*\.?\d*%([eE][-+]?\d+)?>"
syntax match fennelNumber "\v\c<[-+]?0x[0-9A-F]*\.?[0-9A-F]*>"

" Grammar root
syntax cluster fennelTop contains=@Spell,fennelComment,fennelConstant,fennelQuote,fennelKeyword,LuaSpecialValue,fennelSymbol,fennelNumber,fennelString,fennelList,fennelArray,fennelTable,fennelSpecialForm,fennelBoolean

syntax region fennelList matchgroup=fennelParen start="("  end=")" contains=@fennelTop
syntax region fennelArray matchgroup=fennelParen start="\[" end="]" contains=@fennelTop
syntax region fennelTable matchgroup=fennelParen start="{"  end="}" contains=@fennelTop

syntax sync fromstart

" Highlighting
hi def link fennelComment Comment
hi def link fennelSymbol Identifier
hi def link fennelNumber Number
hi def link fennelConstant Constant
hi def link fennelKeyword Keyword
hi def link fennelSpecialForm Special
hi def link LuaSpecialValue Special
hi def link fennelString String
hi def link fennelBuffer String
hi def link fennelStringDelimiter String
hi def link fennelBoolean Boolean

hi def link fennelQuote SpecialChar
hi def link fennelParen Delimiter

let b:current_syntax = "fennel"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: et sw=2 sts=-1 tw=100 fdm=marker
