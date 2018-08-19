function! plumb#system#GetPathSep()
  return "/"
endfunction

function! plumb#system#IsAbsPath(path)
  if a:path ==# ""
    return 0
  endif
  let l:path = plumb#util#Trim(a:path)
  let l:pathHead = strpart(l:path, 0, 1)
  return l:pathHead ==# plumb#system#GetPathSep()
endfunction

function! plumb#system#HasTrailSep(path)
  if a:path ==# ""
    return 0
  endif
  let l:pathTail = strpart(a:path, len(a:path) -1, 1)
  return l:pathTail ==# plumb#system#GetPathSep()
endfunction

function! plumb#system#PathJoin(base, rel)
  if a:base ==# ""
    return a:rel
  endif
  if a:rel ==# ""
    return a:base
  endif
  if plumb#system#HasTrailSep(a:base)
    return a:base . a:rel
  else
    return a:base . "/" . a:rel
  endif
endfunction

function! plumb#system#FileExists(path)
  return filereadable(a:path)
endfunction

function! plumb#system#DirExists(path)
  return isdirectory(a:path)
endfunction
