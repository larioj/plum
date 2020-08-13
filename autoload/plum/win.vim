function! plum#win#Columns()
  let n = winnr()
  let pos = getcurpos()
  200 wincmd h
  let res = 1
  let last = winnr()
  wincmd l
  while last != winnr()
    let res = res + 1
    let last = winnr()
    wincmd l
  endwhile
  execute n . 'wincmd w'
  call setpos('.', pos)
  return res
endfunction

function! plum#win#Rows()
  let n = winnr()
  let pos = getcurpos()
  200 wincmd j
  let res = 1
  let last = winnr()
  wincmd k
  while last != winnr()
    let res = res + 1
    let last = winnr()
    wincmd k
  endwhile
  execute n . 'wincmd w'
  call setpos('.', pos)
  return res
endfunction

function! plum#win#State()
  let n = winnr()
  let pos = getcurpos()
  let cols = []
  let cols_len = plum#win#Columns()
  200 wincmd h
  200 wincmd k
  while len(cols) != cols_len
    let rows = []
    let rows_len = plum#win#Rows()
    while len(rows) != rows_len
      call add(rows, winnr())
      wincmd j
    endwhile
    call add(cols, rows)
    wincmd l
  endwhile
  execute n . 'wincmd w'
  call setpos('.', pos)
  return cols
endfunction

function! plum#win#EqCols(state)
  let state = a:state
  for el in state
    if len(el) != len(state[0])
      return v:false
    endif
  endfor
  return v:true
endfunction

function! plum#win#MinCol(state)
  let state = a:state
  let min = 0
  let i = 1
  while i < len(state)
    if len(state[i]) <= len(state[min])
      let min = i
    endif
    let i = i + 1
  endwhile
  return min
endfunction

function! plum#win#Create(top)
  if ((plum#win#Columns() + 1) * 90 <= &columns)
    botright vsplit
    wincmd l
    enew
    wincmd =
    return
  endif
  let state = plum#win#State()
  if plum#win#EqCols(state)
    let last = winnr()
    " move right
    wincmd l
    " if at rightmost, move leftmost
    if winnr() ==# last
      200 wincmd h
    endif
  else
    200 wincmd h
    let min = plum#win#MinCol(state)
    if min > 0
      execute min . " wincmd l"
    endif
  endif
  if a:top
    200 wincmd k
    split
    wincmd k
  else
    200 wincmd j
    split
    wincmd j
  endif
  enew
endfunction

function! plum#win#Close()
  let nrow = plum#win#Rows()
  if nrow != 1
    close
    return
  endif
  if winnr('$') <= 3
    close
    wincmd =
    return
  endif
  close
  200 wincmd l
  while plum#win#Rows() < 2
    wincmd h
  endwhile
  200 wincmd j
  wincmd L
endfunction

function! s:Min(a, b)
  if a:a < a:b
    return a:a
  else 
    return a:b
  endif
endfunction

function! s:Max(a, b)
  if a:a > a:b
    return a:a
  else 
    return a:b
  endif
endfunction

function! s:GetWidth()
  return 90
endfunction

function! s:GetHeight(ft, term_status)
  let ft = a:ft
  let term_status = a:term_status
  if term_status != ''
    return 20
  endif
  return 30
endfunction

function! s:TabHistory()
  let t:PlumTabHistory = get(t:, 'PlumTabHistory', [])
  return t:PlumTabHistory
endfunction

function! s:WinHistory()
  let w:PlumWinHistory = get(t:, 'PlumWinHistory', [])
  return w:PlumWinHistory
endfunction

function! s:MapLayout(layout, Fn)
  let layout = a:layout
  let Fn = a:Fn
  if layout[0] == 'leaf'
    let node = Fn(layout[1])
    let node.type = 'leaf'
    return node
  endif
  let children = []
  let height = 0
  let width = 0
  let max_child_buffer_lines = 0
  let buffer_lines = 0
  let min_child_unused_lines = &columns + 1
  let unused_lines = 0
  let want_height = 0
  let want_width = 0
  let max_want_height = 0
  let min_want_height_extra = &columns + 1
  for c in layout[1]
    let child = s:MapLayout(c, Fn)
    let height = height + child.height
    let width = width + child.width
    let want_height = want_height + child.want_height
    let max_want_height = s:Max(max_want_height, child.want_height)
    let want_width = want_width + child.want_width
    let max_child_buffer_lines = s:Max(max_child_buffer_lines, child.buffer_lines)
    let buffer_lines = buffer_lines + child.buffer_lines
    let min_child_unused_lines = s:Min(min_child_unused_lines, child.unused_lines)
    let unused_lines = unused_lines + child.unused_lines
    let min_want_height_extra = s:Min(min_want_height_extra, child.min_want_height_extra)
    call add(children, child)
  endfor
  let node = {}
  let node.type = layout[0]
  let node.children = children
  if node.type == 'col'
    let node.width = width / len(children)
    let node.height = height + len(children) - 1
    let node.buffer_lines = buffer_lines
    let node.unused_lines = unused_lines
    let node.want_width = want_width / len(children)
    let node.want_height = want_height + len(children) - 1
  else
    let node.width = width + len(children) - 1
    let node.height = height / len(children)
    let node.buffer_lines = max_child_buffer_lines
    let node.unused_lines = min_child_unused_lines
    let node.want_width = want_width + len(children) - 1
    let node.want_height = max_want_height
  endif
  let node.want_height_extra = node.height - node.want_height
  let node.min_want_height_extra = min_want_height_extra
  return node
endfunction

function! s:WinInfo(winid)
  let win = {}
  let buffer = {}
  let term = {}
  let win.id = a:winid
  let win.nr = win_id2win(win.id)
  let buffer.nr = winbufnr(win.nr)
  let term.status = term_getstatus(buffer.nr)
  let curid = win_getid()
  let curview = winsaveview()
  call win_gotoid(win.id)
  let win.view = winsaveview()
  let win.height = winheight(win.nr)
  let win.width = winwidth(win.nr)
  let buffer.name = bufname(buffer.nr)
  let buffer.ft = &filetype
  let buffer.lines = line('$')
  let win.buffer_lines = buffer.lines
  let win.want_height = s:Min(s:GetHeight(buffer.ft, term.status), buffer.lines)
  let win.want_width = s:GetWidth()
  let win.unused_lines = s:Max(0, win.height - win.buffer_lines)
  let buffer.modifiable = &modifiable
  let win.want_extra = buffer.modifiable
  let win.min_want_height_extra = win.height - win.want_height
  let win.want_height_extra = win.height - win.want_height
  call win_gotoid(curid)
  call winrestview(curview)
  let win.buffer = buffer
  let win.term = term
  return win
endfunction

function! plum#win#TabInfo()
  let tab = {}
  let tab.layout = s:MapLayout(winlayout(), function('s:WinInfo'))
  let tab.restcmd = winrestcmd()
  return tab
endfunction

function! s:ListCmp(lhs, rhs)
  let lhs = a:lhs
  let rhs = a:rhs
  let i = 0
  while i < s:Min(len(lhs), len(rhs))
    if lhs[i] > rhs[i]
      return -1
    elseif lhs[i] < rhs[i]
      return 1
    endif
    let i = i + 1
  endwhile
  return 0
endfunction

function! s:Descend(node)
  let node = a:node
  if node.type == 'leaf'
    return node
  endif
  return s:Descend(node.children[0])
endfunction

function! s:ResetSizes(root, skip_child)
  let root = a:root
  let skip_child = a:skip_child
  let i = 0
  while i < len(root.children)
    let col = root.children[i]
    if col.type == 'leaf'
      let nr = win_id2win(col.id)
      execute nr . 'resize' . col.height
    endif
    if i == skip_child || col.type != 'col'
      let i = i + 1
      continue
    endif
    for node in col.children
      if node.type == 'leaf'
        let nr = win_id2win(node.id)
        execute nr . 'resize' . node.height
      endif
    endfor
    let i = i + 1
  endwhile
endfunction

function! s:ResetViews(node, top)
  let node = a:node
  let top = a:top
  let curview = 0
  let curid = 0
  if top
    let curview = winsaveview()
    let curid = win_getid()
  endif
  if node.type != 'leaf'
    for child in node.children
      call s:ResetViews(child, v:false)
    endfor
  else
    call win_gotoid(node.id)
    call winrestview({'topline': node.view.topline})
  endif
  if top
    call win_gotoid(curid)
    call winrestview(curview)
  endif
endfunction

function! s:Distribute(coins, size)
  let coins = a:coins
  let size = a:size
  let dist = []
  for i in range(1, coins % size)
    call add(dist, [i - 1, 1 + (coins/size)])
  endfor
  if (coins/size) > 0
    for i in range(coins % size + 1, size)
      call add(dist, [i - 1, coins/size])
    endfor
  endif
  return dist
endfunction

function! s:ResizeCol(col)
  let col = a:col
  if col.type != 'col'
    return
  endif
  let rem = col.height % len(col.children)
  let share = col.height / len(col.children)
  let want = []
  let want_extra = []
  let i = len(col.children) - 1
  while i >= 0
    let child = col.children[i]
    if child.want_height < share
      let child.height = child.want_height
      let rem = rem + (share - child.want_height)
    else
      let child.height = share
      call add(want, child)
    endif
    if child.want_extra
      call add(want_extra, child)
    endif
    let i = i - 1
  endwhile
  for [i, share] in s:Distribute(rem, len(want))
    let want_share = s:Min(share, want[i].want_height - want[i].height)
    let want[i].height = want[i].height + want_share
    let rem = rem - want_share
  endfor
  for [i, share] in s:Distribute(rem, len(want_extra))
    let want_extra[i].height = want_extra[i].height + share
    let rem = rem - share
  endfor
  for [i, share] in s:Distribute(rem, len(col.children))
    let col.children[i].height = col.children[i].height + share
    let rem = rem - share
  endfor
  let col.children[0].height = col.children[0].height + rem
  for child in col.children
    if child.type == 'leaf'
      let nr = win_id2win(child.id)
      execute nr . 'resize' . child.height
    endif
  endfor
endfunction

function! plum#win#Open(Load)
  let Load = a:Load
  let hist = s:TabHistory()
  let tab = plum#win#TabInfo()
  call add(hist, tab)
  if tab.layout.width - tab.layout.want_width > s:GetWidth()
    botright vsplit
    call Load()
    return
  endif
  if tab.layout.type == 'leaf' || tab.layout.type == 'col'
    topleft split
    call Load()
    return
  endif
  let order = []
  let i = 0
  while i < len(tab.layout.children)
    let col = tab.layout.children[i]
    call add(order, [col.min_want_height_extra, col.unused_lines, col.want_height_extra, i])
    let i = i + 1
  endwhile
  call sort(order, function('s:ListCmp'))
  let active_col = order[0][3]
  let dest = s:Descend(tab.layout.children[active_col])
  vsplit
  call win_splitmove(win_getid(), dest.id)
  call Load()
  call s:ResetSizes(tab.layout, active_col)
  call s:ResizeCol(plum#win#TabInfo().layout.children[active_col])
  call s:ResetViews(tab.layout, v:true)
  call add(hist, plum#win#TabInfo())
endfunction

function! plum#win#Quit()
  let id = win_getid()
  let tab = plum#win#TabInfo()
  quit
  s:Reset
endfunction
