function! plum#fso2#Open(path, is_alt)
  let [path, is_alt] = [a:path, a:is_alt]
  let cwd = getcwd()
  let is_directory = isdirectory(path[0])
  let open_cmd = get(g:, 'plum_open_cmd', 'split')

  if is_directory
    if !is_alt
      execute open_cmd . ' ' . path[0]
    else
      execute 'lcd ' . path[0]
    endif
    return
  endif

  if is_alt
    execute 'tabe ' . path[0]
  else
    execute open_cmd . ' ' . path[0]
    execute 'lcd ' . cwd
  endif
  if len(path) > 1
    let parts = split(path[1], ',')
    if len(parts) == 2
      call plum#fso#SelectLines(parts[0], parts[1])
    else
      execute parts[0]
    endif
  endif
endfunction

function! plum#fso#OpenFso()
  return [ { a, b -> plum#fso#BestInterp(plum#fso#ReadActivePath()) }
        \, { p, i -> plum#fso2#Open(p, i.key[0:0] ==# 'S') } ]
endfunction
