" Helper functions for fennel-syntax plugin
" Last Change: 2021-06-20
" Author: Mitsuhiro Nakamura <m.nacamura@gmail.com>
" URL: https://github.com/mnacamura/vim-fennel-syntax
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

" Get Lua version from environment.
fun! fennel#GetLuaVersion() abort
  let l:fallback_version = '5.1'

  if !executable('lua')
    return l:fallback_version
  endif

  let l:version_string = system('lua -v')
  if match(l:version_string, '^LuaJIT') > -1
    return '5.1'
  endif

  let l:version = matchstr(l:version_string, '^Lua \zs5\.[1-4]')
  if l:version !=# ''
    return l:version
  endif

  echoerr 'Unknown Lua version, fall back to ' . l:fallback_version
  return l:fallback_version
endfun

" Check if LuaJIT is in path.
fun! fennel#CheckLuajit() abort
  if !executable('lua')
    return 0
  endif

  if match(system('lua -v'), '^LuaJIT') > -1
    return 1
  endif

  return 0
endfun

" vim: et sw=2 sts=-1 tw=100 fdm=marker
