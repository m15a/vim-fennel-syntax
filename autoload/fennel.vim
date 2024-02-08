" Helper functions for fennel-syntax plugin
" Last Change: 2024-02-08
" Author: NACAMURA Mitsuhiro <m15@m15a.dev>
" URL: https://github.com/m15a/vim-fennel-syntax
" License: MIT

if exists('g:autoloaded_fennel')
  finish
endif
let g:autoloaded_fennel = 1

" Get value from a buffer-local or global variable with fall back.
fun! fennel#GetOption(varname, default) abort
  let l:prefixed_varname = 'fennel_' . a:varname
  return get(b:, l:prefixed_varname, get(g:, l:prefixed_varname, a:default))
endfun

" Get Lua version string.
fun! fennel#GetLuaVersionString() abort
  let l:version_string = get(b:, 'fennel_cache_lua_version_string')
  if !l:version_string
    let l:version_string = system('lua -v')
    let b:fennel_cache_lua_version_string = l:version_string
  endif
  return l:version_string
endfun

" Get Lua version from environment.
fun! fennel#GetLuaVersion() abort
  let l:version = get(b:, 'fennel_cache_lua_version')
  if l:version
    return l:version
  else
    unlet l:version
  endif

  let l:fallback_version = '5.1'

  if !executable('lua')
    let b:fennel_cache_lua_version = l:fallback_version
    return l:fallback_version
  endif

  let l:version_string = fennel#GetLuaVersionString()
  if match(l:version_string, '^LuaJIT') > -1
    let b:fennel_cache_lua_version = '5.1'
    return '5.1'
  endif

  let l:version = matchstr(l:version_string, '^Lua \zs5\.[1-4]')
  if l:version !=# ''
    let b:fennel_cache_lua_version = l:version
    return l:version
  endif

  echoerr 'Unknown Lua version, fall back to ' . l:fallback_version
  let b:fennel_cache_lua_version = l:fallback_version
  return l:fallback_version
endfun

" Check if LuaJIT is in path.
fun! fennel#LuaIsLuajit() abort
  let l:is_luajit = get(b:, 'fennel_cache_lua_is_luajit', 'unknown')
  if l:is_luajit !=# 'unknown'
    return l:is_luajit
  else
    unlet l:is_luajit
  endif

  if !executable('lua')
    let b:fennel_cache_lua_is_luajit = 0
    return 0
  endif

  let l:version_string = fennel#GetLuaVersionString()
  if match(l:version_string, '^LuaJIT') > -1
    let b:fennel_cache_lua_is_luajit = 1
    return 1
  endif

  let b:fennel_cache_lua_is_luajit = 0
  return 0
endfun

" vim: et sw=2 sts=-1 tw=100 fdm=marker
