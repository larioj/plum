function! plum#fso#OpenFso()
  return [ { _, _ -> plum#fso#Extract() }
        \, { p, i -> plum#fso#Act(p, i[0] ==# 'S') } ]
endfunction

function! plum#fso#Act(path, new_tab)
  let path = a:path
  let location = 'split '
  if a:new_tab
    let location = 'tabe '
  endif
  execute location . path[0]
  if len(path) > 1
    let parts = split(path[1], ',')
    if len(path) == 2
      let [start, end] = parts
      call s:vselect(start,end)
    else
      execute parts[0]
    endif
  endif
endfunction

function! plum#fso#Extract()
  let paths = filter(s:paths(), { p -> filereadable(p[0]) || isdirectory(p[0]) })
  if len(paths) ==# 0
    return ['', v:false]
  endif
  return [paths[0], v:true]
endfunction

function! s:vselect(start, end)
  let [start, end] = [a:start, a:end]
  call cursor(start, 0)
  execute 'normal! v'
  call cursor(end, 0)
  execute 'normal! $'
endfunction

function! s:paths()
  let original = s:path()
  let paths = [original]
  if trim(original[0][0:0]) != '/'
    let relf = copy(original)
    let file_dir = expand('%:p:h')
    let relf[0] = simplify(file_dir . '/' . relf[0])
    call add(paths, relf)
  endif
  return paths
endfunction

function! s:path()
  let p = plum#util#visual()
  if p != ''
    return p
  endif
  let old = &isfname
  set isfname+=58 " allow ':'
  let p = expand('<cfile>')
  let &isfname = old
  return split(p, ':')
endfunction
