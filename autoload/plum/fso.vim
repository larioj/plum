function! plum#fso#OpenFso()
  return [ { a, b -> plum#fso#BestInterp(plum#fso#ReadActivePath()) }
        \, { p, i -> plum#fso#Act(p, i.key[0:0] ==# 'S') } ]
endfunction

function! plum#fso#Act(path, is_alt)
  let path = a:path
  let is_alt = a:is_alt
  let is_transient = get(b:, 'plum_transient', v:false)
  let is_directory = isdirectory(path[0])

  if is_directory
    if is_alt
      lcd path[0]
    else
      execute 'split ' . path[0]
      let b:plum_transient = v:true
    endif
    return
  endif

  let command = 'split'
  if !is_transient && is_alt
    let command = 'tabe'
  endif
  execute command . ' ' . path[0]
  let b:plum_transient = v:false
  if len(path) > 1
    let parts = split(path[1], ',')
    if len(parts) == 2
      call plum#fso#SelectLines(parts[0], parts[1])
    else
      execute parts[0]
    endif
  endif
endfunction

function! plum#fso#BestInterp(original)
  let original = a:original
  if !len(original)
    return [original, v:false]
  endif
  let paths = filter(plum#fso#OrderedInterps(original),
        \ { _, p -> filereadable(p[0]) || isdirectory(p[0]) })
  if !len(paths)
    return [original, v:false]
  endif
  return [paths[0], v:true]
endfunction

function! plum#fso#SelectLines(start, end)
  let [start, end] = [a:start, a:end]
  call cursor(start, 0)
  execute 'normal! v'
  call cursor(end, 0)
  execute 'normal! $'
endfunction

function! plum#fso#OrderedInterps(original)
  let original = a:original
  if !len(original)
    return []
  endif
  let paths = [original]
  if trim(original[0][0:0]) != '/'
    let relf = copy(original)
    let file_dir = expand('%:p:h')
    let relf[0] = simplify(file_dir . '/' . relf[0])
    call add(paths, relf)
  endif
  return paths
endfunction

function! plum#fso#ReadActivePath()
  let p = plum#util#visual()
  if !len(p)
    let p = plum#util#path()
  endif
  return plum#fso#ParsePath(p)
endfunction

function! plum#fso#ParsePath(str)
  let str = a:str
  if len(str)
    return split(str, ':')
  endif
  return []
endfunction
