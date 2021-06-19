" Helper functions for fennel-syntax plugin
" Last Change: 2021-06-19
" Author: Mitsuhiro Nakamura <m.nacamura@gmail.com>
" URL: https://github.com/mnacamura/vim-fennel-syntax
" License: MIT

if exists('g:autoloaded_fennel')
  finish
endif
let g:autoloaded_fennel = 1

" Get value from a buffer-local or global variable with fall back
fun! fennel#Get(varname, default) abort
  let l:prefixed_varname = 'fennel_' . a:varname
  return get(b:, l:prefixed_varname, get(g:, l:prefixed_varname, a:default))
endfun

" Get Lua version from environment
fun! fennel#GetLuaVersion() abort
  if !executable('lua')
    return '5.1'
  endif
  let l:version = system('lua -v')
  if match(l:version, 'LuaJIT') > -1
    return '5.1'
  elseif match(l:version, 'Lua 5.1') > -1
    return '5.1'
  elseif match(l:version, 'Lua 5.2') > -1
    return '5.2'
  elseif match(l:version, 'Lua 5.3') > -1
    return '5.3'
  elseif match(l:version, 'Lua 5.4') > -1
    return '5.4'
  else
    echoerr 'Unknown Lua version, fall back to 5.1'
    return '5.1'
  endif
endfun

" vim: et sw=2 sts=-1 tw=100 fdm=marker
