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
    execute 'below split ' . context.match
  endif
endfunction

function! plum#fso#IsFso(context)
  let context = a:context
  let path = plum#fso#GetPath(context)
  let context.match = plum#fso#ResolveFso(path)
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
