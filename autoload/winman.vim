function! winman#Layout()
  let [orientation, root] = winlayout()
  if orientation == 'leaf'
    return [[root]]
  endif
  let result = []
  for [type, parent] in root
    if type == 'leaf'
      call add(result, [parent])
      continue
    endif
    let nested = []
    for [_, child] in parent
      call add(nested, child)
    endfor
    call add(result, nested)
  endfor
  return result
endfunction

function! winman#Move(source, dest, layout)
  let [si, sj] = a:source
  let [di, dj] = a:dest
  let layout = a:layout
  let sid = layout[si][sj]
  let did = 0
  let rightbelow = 0
  if dj >= len(layout[di])
    let did = layout[di][-1]
    let rightbelow = 1
  else
    let did = layout[di][dj]
  endif
  call win_splitmove(sid, did, {'rightbelow': rightbelow})
  call remove(layout[si], sj)
  call insert(layout[di], sid, dj)
  return layout
endfunction

function! s:TotalItems(layout)
  let total = 0
  for i in range(len(a:layout))
    let total = total + len(a:layout[i])
  endfor
  return total
endfunction

function! winman#Share(size, total, i)
  let base = a:total / a:size
  let rem = a:total % a:size
  return base + (a:i < rem ? 1 : 0)
endfunction

function! winman#MoveCol(source, dest, layout)
  let [source, dest, layout] = [a:source, a:dest, a:layout]
  let size = len(layout)
  if (source % 2 != size % 2 && source > dest) ||
        \ (source % 2 == size % 2 && source < dest) 
    return winman#Move(
          \ [source, len(layout[source])-1],
          \ [dest, len(layout[dest])],
          \ layout)
  endif
  return winman#Move([source, 0], [dest, 0], layout)
endfunction

function! s:Range(start, end)
  let [start, end] = [a:start, a:end]
  if start > end
    return []
  endif
  return range(start, end)
endfunction

function! winman#BalanceStacks()
  let layout = winman#Layout()
  let size = len(layout)
  let total = s:TotalItems(layout)
  for i in reverse(range(size))
    let share = winman#Share(size, total, i)
    for _ in s:Range(share, len(layout[i])-1)
      call winman#MoveCol(i, i-1, layout)
    endfor
    let with_extra = i - 1
    for _ in s:Range(len(layout[i]), share - 1)
      while(len(layout[with_extra]) <= winman#Share(size, total, with_extra))
        let with_extra = with_extra - 1
      endwhile
      for k in s:Range(with_extra, i - 1)
        call winman#MoveCol(k, k+1, layout)
      endfor
    endfor
  endfor
endfunction

function! winman#GetWin(...)
  let layout = get(a:000, 0, winman#Layout())
  let winid = win_getid()
  for i in range(len(layout))
    for j in range(len(layout[i]))
      if winid == layout[i][j]
        return [i, j]
      endif
    endfor
  endfor
endfunction

function! winman#Fix()
  let [type, root] = winlayout()
  if type == 'col'
    let [_, source] = root[0]
    let [dtype, dest] = root[1]
    if dtype == 'leaf'
      call win_splitmove(source, dest, {'vertical': 1, 'rightbelow': 1})
    else "dtype == 'row'
      let [dtype, dest] = dest[-1]
      if dtype == 'col'
        let dest = dest[0][1]
      endif
      call win_splitmove(source, dest)
    endif
  endif
  call winman#BalanceStacks()
endfunction

function! winman#Open(...)
  let path = get(a:000, 0, '')
  let winid = win_getid()
  let layout = winman#Layout()
  for i in range(len(layout))
    for j in range(len(layout[i]))
      if winid == layout[i][j] && i == 0 && len(layout) > 1
        set splitbelow
      endif
    endfor
  endfor
  execute 'split ' . path
  set nosplitbelow
endfunction

function! winman#AfterClose()
  let [type, _] = winlayout()
  if type == 'col'
    wincmd j
    wincmd L
  endif
  call winman#BalanceStacks()
endfunction

function! winman#Close()
  quit
  call winman#AfterClose()
endfunction

function! winman#EnableWinman()
  command! -bang -complete=file -nargs=* WinmanOpen
      \ call winman#Open(<q-args>)
  command! -nargs=0 WinmanAfterClose call winman#AfterClose()
  augroup winman
    autocmd WinNew * :call winman#Fix()
  augroup END
endfunction
