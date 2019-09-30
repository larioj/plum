function! plum#fso#OpenFso()
  return plum#CreateAction(
        \ 'plum#fso#OpenFso',
        \ function('plum#fso#IsFso'),
        \ function('plum#fso#ApplyOpenFso'))
endfunction

function! plum#fso#ApplyOpenFso(context)
  let context = a:context
  if context.shift
    execute 'tabe ' . context.match
  else
    execute 'split ' . context.match
  endif
  if has_key(context, 'address')
    let address = context.address
    if address.type ==# 'LineNumber'
      execute address.line
    elseif address.type ==# 'Range'
      call cursor(address.start, 0)
      execute 'normal! v'
      call cursor(address.end, 0)
      execute 'normal! $'
    endif
  endif
endfunction

function! plum#fso#IsFso(context)
  let context = a:context
  let path = plum#fso#GetPath(context)
  let address = plum#fso#GetAddress(context.mode)
  let context.match = plum#fso#ResolveFso(path)
  let address.path = context.match
  let context.address = address
  return context.match !=# ''
endfunction

function! plum#fso#ResolveFso(path)
  let path = a:path
  let paths = plum#fso#AllPaths(path)
  for p in [paths.original, paths.relative_to_file]
    if filereadable(p) || isdirectory(p)
      return p
    endif
  endfor
  return ''
endfunction

function! plum#fso#GetPath(context)
  let context = a:context
  let path = context.content
  if context.mode ==# 'n' || context.mode ==# 'i'
    let path = context.path
  endif
  return path
endfunction

function! plum#fso#GetAddress(mode)
  let mode = a:mode
  if mode ==# 'v'
    return plum#fso#ParseAddress(trim(
          \ plum#extensions#GetVisualSelection()))
  elseif mode ==# 'n' || mode ==# 'i'
    let path = expand('<cfile>')
    let olda = @a
    execute 'normal! "ay$'
    let ctoe = @a
    let @a = olda
    let address = plum#fso#ParseAddress(ctoe)
    if address.type !=# 'NotAddress'
      let address.path = path
    endif
    return address
  else
    return { 'type' : 'NotAddress' }
  endif
endfunction

function! plum#fso#ParseAddress(path)
  let path = a:path
  let haspathonly = '\v(\f+)'
  let haslinenumonly = '\v(\f+):(\d+)'
  let hasrange = '\v(\f+):(\d+),(\d+)'
  let address = { 'type' : 'NotAddress' }
  if match(path, hasrange) ==# 0
    let matchgroups = matchlist(path, hasrange)
    let address = { 'type' : 'Range' }
    let address.path = matchgroups[1]
    let address.start = matchgroups[2]
    let address.end = matchgroups[3]
  elseif match(path, haslinenumonly) ==# 0
    let matchgroups = matchlist(path, haslinenumonly)
    let address = { 'type' : 'LineNumber' }
    let address.path = matchgroups[1]
    let address.line = matchgroups[2]
  elseif match(path, haspathonly) ==# 0
    let matchgroups = matchlist(path, haspathonly)
    let address = { 'type' : 'PathOnly' }
    let address.path = matchgroups[1]
  endif
  return address
endfunction

function! plum#fso#AllPaths(path)
  let path = a:path
  let file_dir = expand('%:p:h')
  " TODO(larioj): Figure out a way to handle abs paths
  let relative_to_file = simplify(file_dir . '/' . path)
  return {
        \ 'original' : path,
        \ 'relative_to_file' : relative_to_file
        \ }
endfunction
