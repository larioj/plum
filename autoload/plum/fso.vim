function! plum#fso#OpenFso()
  return [ { a, b -> plum#fso#bestpath(plum#fso#path()) }
        \, { p, i -> plum#fso#Act(p, i.key[0:0] ==# 'S') } ]
endfunction

function! plum#fso#Act(path, new_tab)
  let path = a:path
  if isdirectory(path[0])
    lcd path[0]
    return
  endif
  let location = 'split '
  if a:new_tab
    let location = 'tabe '
  endif
  execute location . path[0]
  if len(path) > 1
    let parts = split(path[1], ',')
    if len(parts) == 2
      call plum#fso#vselect(parts[0], parts[1])
    else
      execute parts[0]
    endif
  endif
endfunction

function! plum#fso#bestpath(original)
  let paths = filter(plum#fso#paths(a:original),
        \ { _, p -> filereadable(p[0]) || isdirectory(p[0]) })
  if len(paths) ==# 0
    return ['', v:false]
  endif
  return [paths[0], v:true]
endfunction

function! plum#fso#vselect(start, end)
  let [start, end] = [a:start, a:end]
  call cursor(start, 0)
  execute 'normal! v'
  call cursor(end, 0)
  execute 'normal! $'
endfunction

function! plum#fso#paths(original)
  let original = a:original
  let paths = [original]
  if trim(original[0][0:0]) != '/'
    let relf = copy(original)
    let file_dir = expand('%:p:h')
    let relf[0] = simplify(file_dir . '/' . relf[0])
    call add(paths, relf)
  endif
  return paths
endfunction

function! plum#fso#path()
  let p = plum#util#visual()
  if p != ''
    return p
  endif
  return split(plum#util#path(), ':')
endfunction
