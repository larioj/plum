function! plum#system#GetPathSep()
  return "/"
endfunction

function! plum#system#IsAbsPath(path)
  if a:path ==# ""
    return 0
  endif
  let l:path = plum#util#Trim(a:path)
  let l:pathHead = strpart(l:path, 0, 1)
  return l:pathHead ==# plum#system#GetPathSep()
endfunction

function! plum#system#HasTrailSep(path)
  if a:path ==# ""
    return 0
  endif
  let l:pathTail = strpart(a:path, len(a:path) -1, 1)
  return l:pathTail ==# plum#system#GetPathSep()
endfunction

function! plum#system#PathJoin(base, rel)
  if a:base ==# ""
    return a:rel
  endif
  if a:rel ==# ""
    return a:base
  endif
  if plum#system#HasTrailSep(a:base)
    return a:base . a:rel
  else
    return a:base . "/" . a:rel
  endif
endfunction

function! plum#system#FileExists(path)
  return filereadable(a:path)
endfunction

function! plum#system#DirExists(path)
  return isdirectory(a:path)
endfunction
