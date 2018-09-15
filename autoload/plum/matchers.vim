function! plum#matchers#MatchFso(options, FsoExists)
  let l:mode = a:options['mode']
  if l:mode ==# 'v'
    let l:content = a:options['vselection']
  elseif l:mode ==# 'n' || l:mode == 'i'
    let l:content = a:options['cfile']
  else
    let a:options['status'] = 'unknown mode'
    return 0
  endif
  let l:content = plum#util#Trim(l:content)

  " Absolute file
  if plum#system#IsAbsPath(l:content)
    if a:FsoExists(l:content)
      let a:options['match'] = l:content
      return 1
    else
      let a:options['status'] = "Match failed: Absolute path does not exist"
      return 0
    endif
  endif

  " Relative to plum base
  if exists('b:Plum_BaseDir')
    let l:fullpath =  plum#system#PathJoin(b:Plum_BaseDir, l:content)
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
  let l:fullpath = plum#system#PathJoin(getcwd(), l:content)
  if a:FsoExists(l:fullpath)
    let a:options['match'] = l:fullpath
    return 1
  endif

  " File relative to buffer
  let l:bufferdir = expand('%:p:h')
  let l:fullpath =  plum#system#PathJoin(l:bufferdir, l:content)
  if a:FsoExists(l:fullpath)
    let a:options['match'] = l:fullpath
    return 1
  endif

  let a:options['status'] = "Match Failed: End of function"
  return 0
endfunction

function! plum#matchers#File(options)
  return plum#matchers#MatchFso(a:options, function('plum#system#FileExists'))
endfunction

function! plum#matchers#Dir(options)
  return plum#matchers#MatchFso(a:options, function('plum#system#DirExists'))
endfunction

function! plum#matchers#BashCommand(options)
  let l:prefix = "$ "
  let l:mode = a:options['mode']
  if l:mode ==# 'v'
    let l:content = a:options['vselection']
  elseif l:mode ==# 'n' || l:mode == 'i'
    let l:cur = line('.')
    let l:curline = getline(l:cur)
    let l:lines = [l:curline]
    while l:curline[-1:] ==# "\\"
      let l:cur += 1
      let l:curline = getline(l:cur)
      let l:lines = l:lines + [l:curline]
    endwhile
    let l:content = join(l:lines, "\n")
  else
    let a:options['status'] = 'unknown mode'
    return 0
  endif
  let l:content = plum#util#Trim(l:content)
  let l:actual = strpart(l:content, 0, len(l:prefix))
  if l:prefix ==# l:actual
    let a:options['match'] = strpart(l:content, len(l:prefix), len(l:content))
    return 1
  endif
  let a:options['status'] = "Match Failed: End of function"
  return 0
endfunction

function! plum#matchers#TrimmedLineStartsWith(options, preffix)
  let l:mode = a:options['mode']
  if l:mode ==# 'v'
    let l:content = a:options['vselection']
  elseif l:mode ==# 'n' || l:mode == 'i'
    let l:content = a:options['line']
  else
    let a:options['status'] = 'unknown mode'
    return 0
  endif
  let l:content = plum#util#Trim(l:content)
  let l:actual = strpart(l:content, 0, len(a:preffix))
  if a:preffix ==# l:actual
    let a:options['match'] = strpart(l:content, len(a:preffix), len(l:content))
    return 1
  endif
  let a:options['status'] = "Match Failed: End of function"
  return 0
endfunction

function! plum#matchers#TrimmedLineStartsWithCashSpace(options)
  return plum#matchers#TrimmedLineStartsWith(a:options, '$ ')
endfunction

function! plum#matchers#TrimmedLineStartsWithColonSpace(options)
  return plum#matchers#TrimmedLineStartsWith(a:options, ': ')
endfunction

function! plum#matchers#Test()
  let l:options = { 'line' : ': hello', 'mode' : 'n', 'shift' : 0, }
  if !plum#matchers#TrimmedLineStartsWithColonSpace(l:options) ||
      \ get(l:options, 'match', '') !=# 'hello'
    echo 'Failed: Colon True'
  endif

  let l:options = { 'line' : '$ hello', 'mode' : 'n', 'shift' : 0, }
  if plum#matchers#TrimmedLineStartsWithColonSpace(l:options)
    echo 'Failed: Colon False'
  endif

  let l:options = { 'cfile': 'plugin', 'mode' : 'n', 'shift' : 0, }
  if !plum#matchers#Dir(l:options)
    echo l:options['status']
    echo 'Failed: Dir'
  endif
endfunction
