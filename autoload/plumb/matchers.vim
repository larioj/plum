function! plumb#matchers#MatchFso(options, FsoExists)
  let l:mode = a:options['mode']
  if l:mode ==# 'v'
    let l:content = a:options['vselection']
  elseif l:mode ==# 'n' || l:mode == 'i'
    let l:content = a:options['cfile']
  else
    let a:options['status'] = 'unknown mode'
    return 0
  endif
  let l:content = plumb#util#Trim(l:content)

  " Absolute file
  if plumb#system#IsAbsPath(l:content)
    if a:FsoExists(l:content)
      let a:options['match'] = l:content
      return 1
    else
      let a:options['status'] = "Match failed: Absolute path does not exist"
      return 0
    endif
  endif

  " Relative to plumb base
  if exists('b:Plumb_BaseDir')
    let l:fullpath =  plumb#system#PathJoin(b:Plumb_BaseDir, l:content)
    if a:FsoExists(l:fullpath)
      let a:options['match'] = l:fullpath
      return 1
    endif
  endif

  " Relative path
  if a:FsoExists(l:content)
    let a:options['match'] = l:content
    return 1
  endif

  " File relative to cwd
  let l:fullpath = plumb#system#PathJoin(getcwd(), l:content)
  if a:FsoExists(l:fullpath)
    let a:options['match'] = l:fullpath
    return 1
  endif

  " File relative to buffer
  let l:bufferdir = expand('%:p:h')
  let l:fullpath =  plumb#system#PathJoin(l:bufferdir, l:content)
  if a:FsoExists(l:fullpath)
    let a:options['match'] = l:fullpath
    return 1
  endif

  let a:options['status'] = "Match Failed: End of function"
  return 0
endfunction

function! plumb#matchers#File(options)
  return plumb#matchers#MatchFso(a:options, function('plumb#system#FileExists'))
endfunction

function! plumb#matchers#Dir(options)
  return plumb#matchers#MatchFso(a:options, function('plumb#system#DirExists'))
endfunction

function! plumb#matchers#TrimmedLineStartsWith(options, preffix)
  let l:mode = a:options['mode']
  if l:mode ==# 'v'
    let l:content = a:options['vselection']
  elseif l:mode ==# 'n' || l:mode == 'i'
    let l:content = a:options['line']
  else
    let a:options['status'] = 'unknown mode'
    return 0
  endif
  let l:content = plumb#util#Trim(l:content)
  let l:actual = strpart(l:content, 0, len(a:preffix))
  if a:preffix ==# l:actual
    let a:options['match'] = strpart(l:content, len(a:preffix), len(l:content))
    return 1
  endif
  let a:options['status'] = "Match Failed: End of function"
  return 0
endfunction

function! plumb#matchers#TrimmedLineStartsWithCashSpace(options)
  return plumb#matchers#TrimmedLineStartsWith(a:options, '$ ')
endfunction

function! plumb#matchers#TrimmedLineStartsWithColonSpace(options)
  return plumb#matchers#TrimmedLineStartsWith(a:options, ': ')
endfunction

function! plumb#matchers#Test()
  let l:options = { 'line' : ': hello', 'mode' : 'n', 'shift' : 0, }
  if !plumb#matchers#TrimmedLineStartsWithColonSpace(l:options) ||
      \ get(l:options, 'match', '') !=# 'hello'
    echo 'Failed: Colon True'
  endif

  let l:options = { 'line' : '$ hello', 'mode' : 'n', 'shift' : 0, }
  if plumb#matchers#TrimmedLineStartsWithColonSpace(l:options)
    echo 'Failed: Colon False'
  endif

  let l:options = { 'cfile': 'plugin', 'mode' : 'n', 'shift' : 0, }
  if !plumb#matchers#Dir(l:options)
    echo l:options['status']
    echo 'Failed: Dir'
  endif
endfunction
