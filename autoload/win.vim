" Do not use any of these functions

function! win#Layout(...)
  let layout = get(a:000, 0, winlayout())
  if layout[0] == 'leaf'
    return [[layout[1]]]
  endif
  if layout[0] == 'col'
    return [map(layout[1], {_, c -> c[1]})]
  endif
  let res = []
  for col in layout[1]
    if col[0] == 'leaf'
      call add(res, [col[1]])
    else
      call add(res, map(col[1], {_, c -> c[1]}))
    endif
  endfor
  return res
endfunction

function! win#Distribute(lines, reqs, shares)
  let [lines, reqs, shares] = [a:lines, a:reqs, a:shares]
  if lines <= 0
    return [lines, shares]
  endif
  let want = range(len(reqs))
  while len(want) && lines
    let still_want = []
    let share = lines / len(want)
    for i in want
      if i == len(shares)
        call add(shares, 0)
      endif
      let available = share == 0 && lines > 0 ? 1 : share
      let mine = min([available, max([0, reqs[i] - shares[i]])])
      let shares[i] = shares[i] + mine
      let lines = lines - mine
      if shares[i] < reqs[i]
        call add(still_want, i)
      endif
    endfor
    let want = still_want
  endwhile
  return [lines, shares]
endfunction

function! win#DistributeAllInStages(coins, staged_reqs)
  let [coins, staged_reqs] = [a:coins, a:staged_reqs]
  let max_coins = coins
  let shares = []
  for stage in staged_reqs
    let [coins, shares] = win#Distribute(coins, stage, shares)
  endfor
  if coins > 0
    let reqs = map(range(len(shares)), {_ -> max_coins})
    let [coins, shares] = win#Distribute(coins, reqs, shares)
  endif
  return shares
endfunction

function! win#Requirements(winid)
  let winid = a:winid
  let win = getwininfo(winid)[0]
  let bufnr = win.bufnr
  let buf = getbufinfo(bufnr)[0]
  let modifiable = getbufvar(bufnr, '&modifiable')
  let terminal = win.terminal
  let req = 1
  let want = min([25, buf.linecount])
  let enough = modifiable ? max([15, buf.linecount]) : buf.linecount
  return [req, want, enough]
endfunction

function! win#AllRequirements(...)
  let layout = get(a:000, 0, win#Layout())
  let result = deepcopy(layout)
  for col in range(len(layout))
    for row in range(len(layout[col]))
      let result[col][row] = win#Requirements(layout[col][row])
    endfor
  endfor
  return result
endfunction

function! win#ColumnRequirements(col, ...)
  let [col, layout] = [a:col, get(a:000, 0, win#Layout())]
  let reqs = []
  let wants = []
  let enoughs = []
  for winid in layout[col]
    let [r, w, e] = win#Requirements(winid)
    call add(reqs, r)
    call add(wants, w)
    call add(enoughs, e)
  endfor
  return [reqs, wants, enoughs]
endfunction

function! win#OptimizeWidth(...)
  let layout = get(a:000, 0, win#Layout())
  let req_width = get(g:, 'plum_min_width', 90)
  let columns = &columns - len(layout) + 1
  let reqs = map(range(len(layout)), {_ -> req_width})
  return win#DistributeAllInStages(columns, [reqs]) 
endfunction

function! win#OptimizeHeight(col, ...)
  let [col, layout] = [a:col, get(a:000, 0, win#Layout())]
  let lines = &lines - 2 - len(layout[col]) + 1
  let reqs = win#ColumnRequirements(col, layout)
  return win#DistributeAllInStages(lines, reqs)
endfunction

function! win#OptimizeHeights(...)
  let layout = get(a:000, 0, win#Layout())
  let heights = []
  for col in range(len(layout))
    call add(heights, win#OptimizeHeight(col, layout))
  endfor
  return heights
endfunction

function! win#ResizeCmd(...)
  let layout = get(a:000, 0, win#Layout())
  let widths = get(a:000, 1, win#OptimizeWidth(layout))
  let heights = get(a:000, 2, win#OptimizeHeights(layout))
  let cmd = []
  for col in range(len(layout))
    let width = widths[col]
    for row in range(len(layout[col]))
      let height = heights[col][row]
      let winid = layout[col][row]
      let winnr = win_id2win(winid)
      let win = getwininfo(winid)[0]
      if win.height != height
        call add(cmd, winnr . ' resize ' . height . '|')
      endif
      if win.width != width
        call add(cmd, 'vert ' . winnr . ' resize ' . height . '|')
      endif
    endfor
    return join(cmd, ' ')
  endfor
endfunction

function! win#Resize(...)
  let layout = get(a:000, 0, win#Layout())
  let widths = get(a:000, 1, win#OptimizeWidth(layout))
  let heights = get(a:000, 2, win#OptimizeHeights(layout))
  exe win#ResizeCmd(layout, widths, heights)
endfunction

function! win#Satisfaction(col, row, ...)
  let [col, row, layout] = [a:col, a:row, get(a:000, 0, win#Layout())]
  let height = get(a:000, 1, win#OptimizeHeights(layout))
  let req = get(a:000, 2, win#AllRequirements(layout))
  return [ height[col][row] > req[col][row][0] 
       \ , height[col][row] - req[col][row][1] 
       \ , height[col][row] - req[col][row][2] ]
endfunction

function! s:ListCmp(lhs, rhs)
  let lhs = a:lhs
  let rhs = a:rhs
  let i = 0
  while i < min([len(lhs), len(rhs)])
    if lhs[i] < rhs[i]
      return -1
    elseif lhs[i] > rhs[i]
      return 1
    endif
    let i = i + 1
  endwhile
  return 0
endfunction

function! s:ListMin(a, b)
  if s:ListCmp(a:a, a:b) < 0
    return a:a
  else
    return a:b
  endif
endfunction

function! win#ColSatisfaction(col, ...)
  let [col, layout] = [a:col, get(a:000, 0, win#Layout())]
  let height = get(a:000, 1, win#OptimizeHeights(layout))
  let req = get(a:000, 2, win#AllRequirements(layout))
  let sat = {}
  for row in range(len(layout[col]))
    let winsat = win#Satisfaction(col, row, layout, height, req)
    let sat.min = s:ListMin(get(sat, 'min', winsat), winsat)
  endfor
  return sat.min
endfunction

function! win#ColumnOrder(...)
  let layout = get(a:000, 0, win#Layout())
  let height = get(a:000, 1, win#OptimizeHeights(layout))
  let req = get(a:000, 2, win#AllRequirements(layout))
  let order = []
  for col in range(len(layout))
    let sat = win#ColSatisfaction(col, layout, height, req)
    call add(sat, col)
    call add(order, sat)
  endfor
  call sort(order, function('s:ListCmp'))
  return order
endfunction

function! win#LayoutDelete(winid, ...)
  let [winid, layout] = [a:winid, get(a:000, 0, win#Layout())]
  for col in range(len(layout))
    if len(layout[col]) == 1 && layout[col][0] == winid
      call remove(layout, col)[0]
      return [col]
    endif
    for row in range(len(layout[col]))
      if layout[col][row] == winid
        call remove(layout[col], row)
        return [col, row]
      endif
    endfor
  endfor
  return []
endfunction

function! win#Move(...)
  let id = get(a:000, 0, win_getid())
  let is_term = get(a:000, 1, v:false)
  let layout = get(a:000, 2, win#Layout())
  let without_id = deepcopy(layout)
  let coord = win#LayoutDelete(id, without_id)
  if len(coord) < 2
    return
  endif
  let [col, row] = coord
  let order = win#ColumnOrder(without_id)
  let active_col = order[-1][-1]
  if active_col == col && row == 0
    return
  endif
  let dest = is_term ? without_id[active_col][-1] : without_id[active_col][0]
  let opt = { 'rightbelow' : is_term }
  call win_splitmove(id, dest, opt)
endfunction
