" Helper functions for fennel-syntax plugin
" Last Change: 2021-06-20
" Author: Mitsuhiro Nakamura <m.nacamura@gmail.com>
" URL: https://github.com/mnacamura/vim-fennel-syntax
" License: MIT

if exists('g:autoloaded_fennel')
  finish
endif
let g:autoloaded_fennel = 1

" Get value from a buffer-local or global variable with fall back
fun! fennel#GetOption(varname, default) abort
  let l:prefixed_varname = 'fennel_' . a:varname
  return get(b:, l:prefixed_varname, get(g:, l:prefixed_varname, a:default))
endfun

" Get Lua version from environment
fun! fennel#GetLuaVersion() abort
  if !executable('lua')
    return '5.1'
  endif

  let l:version_string = system('lua -v')
  if match(l:version_string, '^LuaJIT') > -1
    return '5.1'
  endif

  let l:version_number = matchstr(l:version_string, '^Lua \zs5\.[1-4]')
  if l:version_number !=# ''
    return l:version_number
  endif

  echoerr 'Unknown Lua version, fall back to 5.1'
  return '5.1'
endfun

" vim: et sw=2 sts=-1 tw=100 fdm=marker
