" Vim syntax file
" Language: Fennel
" Last Change: 2021-06-20
" Maintainer: Mitsuhiro Nakamura <m.nacamura@gmail.com>
" URL: https://github.com/mnacamura/vim-fennel-syntax
" License: MIT

if !exists('b:did_fennel_syntax')
  finish
endif

if !fennel#GetOption('use_luajit', fennel#CheckLuajit())
  finish
endif

syn keyword fennelLuaKeyword bit.tobit bit.tohex bit.bnot bit.band bit.bor bit.bxor bit.lshift
syn keyword fennelLuaKeyword bit.rshift bit.arshift bit.rol bit.ror bit.bswap
syn keyword fennelLuaKeyword ffi.cdef ffi.load ffi.new ctype ffi.typeof ffi.cast ffi.metatype
syn match fennelLuaKeyword /\<ffi\.C/
syn keyword fennelLuaKeyword ffi.gc ffi.sizeof ffi.alignof ffi.offsetof ffi.istype ffi.errno
syn keyword fennelLuaKeyword ffi.string ffi.copy ffi.fill ffi.abi ffi.os ffi.arch
syn keyword fennelLuaKeyword jit.on jit.off jit.flush jit.status jit.version jit.version_num
syn keyword fennelLuaKeyword jit.os jit.arch
syn keyword fennelLuaKeyword jit.opt.start
" https://luajit.org/ext_jit.html:
" The functionality provided by this module is still in flux and therefore undocumented.
syn match fennelLuaKeyword /\<jit\.util/

" vim: et sw=2 sts=-1 tw=100 fdm=marker
