function! plum#tree#OpenFso()
  return [ { a, trigger -> plum#fso#BestInterp(plum#fso#ParsePath(s:TreePathUnderCursor(trigger.mode))) }
        \, { p, i -> plum#fso#Act(p, i.key[0:0] ==# 'S') } ]
endfunction

function! s:TreePathUnderCursor(mode)
  let mode = a:mode
  if mode !=# 'n' && mode !=# 'i'
    return ''
  endif
  let original = winsaveview()
  let sep = ''
  let path = ''
  let lastPathPos = [-1, -1, -1, -1, -1]
  while lastPathPos[1] !=# getpos('.')[1]
    let lastPathPos = getpos('.')
    let section = plum#util#path()
    if section == ''
      call winrestview(original)
      return path
    else
      let path = section . sep . path
      let sep = '/'
    endif

    let lastColPos = []
    while !s:IsTrunkChar(s:GetCharUnderCursor()) && lastColPos !=# getpos('.')
      let lastColPos = getpos('.')
      execute 'normal! h'
    endwhile

    let lastRowPos = []
    while s:IsTrunkChar(s:GetCharUnderCursor()) && lastRowPos !=# getpos('.')
      let lastRowPos = getpos('.')
      execute 'normal! k'
    endwhile
  endwhile
  call winrestview(original)
  return path
endfunction

function! s:GetCharUnderCursor()
  return matchstr(getline('.'), '\%' . col('.') . 'c.')
endfunction

function! s:IsTrunkChar(c)
  return a:c ==# '├' ||
       \ a:c ==# '│' ||
       \ a:c ==# '└'
endfunction
