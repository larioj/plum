function! plum#layout#Layout(...)
  let layout = get(a:000, 0, winlayout())
  let is_root = get(a:000, 1, v:true)
  let root = get(a:000, 2, {'type': 'root', 'leafs': {}, 'traversal': [], 'original_layout': deepcopy(layout)})
  let type = layout[0]
  let children = layout[1]
  if type == 'leaf'
    let id = layout[1]
    let leaf = {'type': 'leaf', 'id': id, 'root': root}
    let root.leafs[id] = leaf
    call add(root.traversal, leaf)
    if is_root
      let col = {'type': 'col', 'children': [leaf], 'root': root}
      call add(root.traversal, col)
      let row = {'type': 'row', 'children': [col], 'root': root}
      call add(root.traversal, row)
      let leaf.parent = col
      let col.parent = row
      let row.parent = root
      let root.layout = row
      return root
    else
      return leaf
    endif
  elseif type == 'col'
    let col = {'type': 'col', 'children': [], 'root': root}
    for c in children
      let child = plum#layout#Layout(c, v:false, root)
      let child.parent = col
      call add(col.children, child)
    endfor
    call add(root.traversal, col)
    if is_root
      let row = {'type': 'row', 'children': [col], 'root': root}
      call add(root.traversal, row)
      let col.parent = row
      let row.parent = root
      let root.layout = row
      return root
    else
      return col
    endif
  else
    let row = {'type': 'row', 'children': [], 'root': root}
    for c in children
      let child = plum#layout#Layout(c, v:false, root)
      if child.type == 'leaf'
        let col = {'type': 'col', 'children': [child], 'root': root}
        call add(root.traversal, col)
        let child.parent = col
        let col.parent = row
        call add(row.children, col)
      else
        let child.parent = row
        call add(row.children, child)
      endif
    endfor
    call add(root.traversal, row)
    if is_root
      let row.parent = root
      let root.layout = row
      return root
    else
      return row
    endif
  endif
endfunction

function! plum#layout#Traversal(...)
  let node = get(a:000, 0, plum#layout#Layout())
  let traversal = get(a:000, 1, [])
  if node.type == 'root'
    return node.traversal
  endif
  if node.type != 'leaf'
    for c in node.children
      call plum#layout#Traversal(c, traversal)
    endfor
  endif
  call add(traversal, node)
  return traversal
endfunction

function! plum#layout#Window(winid)
  let winid = a:winid
  let wininfo = getwininfo(winid)[0]
  let bufnr = wininfo.bufnr
  let bufinfo = getbufinfo(bufnr)[0]
  let modifiable = getbufvar(bufnr, '&modifiable')
  let terminal = wininfo.terminal
  let term_status = term_getstatus(bufnr)
  let win = {}
  let win.id = winid
  let win.width = wininfo.width
  let win.require_width = get(g:, 'plum_require_width', 90)
  let win.height = wininfo.height
  let win.require_height = terminal && term_status != 'finished' ? 3 : 1
  let win.want_height = min([25, bufinfo.linecount])
  let win.enough_height = 
        \ modifiable ? max([15, bufinfo.linecount]) : bufinfo.linecount
  let win.terminal_status = term_status
  return win
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

function! s:MinSat(a, b)
  if s:ListCmp(a:a, a:b) < 0
    return a:a
  else
    return a:b
  endif
endfunction

function! plum#layout#Tab(...)
  let root = get(a:000, 0, plum#layout#Layout())
  let WinFn = get(a:000, 1, {id -> plum#layout#Window(id)})
  for node in root.traversal
    if node.type == 'leaf'
      let win = WinFn(node.id)
      call extend(node, win)
    elseif node.type == 'col'
      for child in node.children
        let node.height =
              \ get(node, 'height', -1) + child.height + 1
        let node.require_height =
              \ get(node, 'require_height', -1) + child.require_height + 1
        let node.want_height =
              \ get(node, 'want_height', -1) + child.want_height + 1
        let node.enough_height =
              \get(node, 'enough_height', -1) + child.enough_height + 1
        let node.width = child.width
        let node.require_width =
              \max([get(node, 'require_width', 0), child.require_width])
      endfor
    else "node.type == 'row'
      for child in node.children
        let node.height = child.height
        let node.require_height =
              \ max([get(node, 'require_height', 0), child.require_height])
        let node.want_height =
              \ max([get(node, 'want_height', 0), child.want_height])
        let node.enough_height =
              \ max([get(node, 'enough_height', 0), child.enough_height])
        let node.width = get(node, 'width', -1) + child.width + 1
        let node.require_width =
              \ get(node, 'require_width', -1) + child.require_width + 1  
      endfor
    endif
  endfor
  return root
endfunction

function! plum#layout#Distribute(lines, reqs, shares)
  let lines = a:lines
  let reqs = a:reqs
  let shares = a:shares
  let all = []
  for i in range(len(reqs))
    call add(all, {'req': reqs[i], 'share': get(shares, i, 0)})
  endfor
  let want = all
  while len(want) && lines
    let still_want = []
    let share = lines / len(want)
    for el in want
      let available = share == 0 && lines > 0 ? 1 : share
      let mine = min([available, max([0, el.req - el.share])])
      let el.share = el.share + mine
      let lines = lines - mine
      if el.share < el.req
        call add(still_want, el)
      endif
    endfor
    let want = still_want
  endwhile
  return [lines, map(all, {_, el -> el.share})]
endfunction

function! plum#layout#DistributeInStages(coins, staged_reqs, shares)
  let coins = a:coins
  let staged_reqs = a:staged_reqs
  let shares = a:shares
  for stage in staged_reqs
    let [coins, shares] = plum#layout#Distribute(coins, stage, shares)
  endfor
  return [coins, shares]
endfunction

function! plum#layout#Resize(...)
  let node = get(a:000, 0, plum#layout#Tab())
  if node.type == 'root'
    call plum#layout#Resize(node.layout)
  endif
  if node.type == 'col'
    let lines = node.height - len(node.children) + 1
    let reqs = map(copy(node.children), {_, c -> c.require_height})
    let wants = map(copy(node.children), {_, c -> c.want_height})
    let enough = map(copy(node.children), {_, c -> c.enough_height})
    let rest = map(copy(node.children), {_ -> lines})
    let [_, heights] = plum#layout#DistributeInStages(
          \ lines, [reqs, wants, enough, rest], [])
    for i in range(len(node.children))
      let node.children[i].height = heights[i]
      let node.children[i].width = node.width
      call plum#layout#Resize(node.children[i])
    endfor
  endif
  if node.type == 'row'
    let cols = node.width - len(node.children) + 1
    let reqs = map(copy(node.children), {_, c -> c.require_width})
    let rest = map(copy(node.children), {_ -> cols})
    let [_, widths] = plum#layout#DistributeInStages(
          \ cols, [reqs, rest], []) 
    for i in range(len(node.children))
      let node.children[i].height = node.height
      let node.children[i].width = widths[i]
      call plum#layout#Resize(node.children[i])
    endfor
  endif
  return node
endfunction

function! plum#layout#ResizeCmd(...)
  let top = get(a:000, 0, plum#layout#Resize())
  let cmds = []
  for node in plum#layout#Traversal(top)
    if node.type == 'leaf'
      let nr = win_id2win(node.id)
      if nr
        call add(cmds, nr . 'resize ' . node.height)
        call add(cmds, 'vert ' . nr . 'resize ' . node.width)
      endif
    endif
  endfor
  let cmd = join(cmds, '|') . '|'
  " do twice since vim does not seem to respect its own command.
  return cmd . cmd
endfunction

function! plum#layout#Satisfaction(...)
  let top = get(a:000, 0, plum#layout#Tab())
  for node in plum#layout#Traversal(top)
    if node.type == 'leaf'
      let node.satisfaction =
        \ [ node.height >= node.require_height
        \ , node.height - node.want_height
        \ , node.height - node.enough_height
        \ ]
    else
      for child in node.children
        let node.satisfaction = s:MinSat(
              \ get(node, 'satisfaction', child.satisfaction), child.satisfaction)
      endfor
    endif
  endfor
  if top.type == 'root'
    return top.layout.satisfaction
  endif
  return top.satisfaction
endfunction

function! plum#layout#ColumnOrder(...)
  let root = get(a:000, 0, plum#layout#Tab())
  let order = []
  for i in range(len(root.layout.children))
    let child = root.layout.children[i]
    let sat = plum#layout#Satisfaction(child)
    call add(sat, i)
    call add(order, sat)
  endfor
  call sort(order, function('s:ListCmp'))
  return order
endfunction

function! plum#layout#Move(...)
  let winid = get(a:000, 0, win_getid())
  let views = get(a:000, 1, plum#layout#GetViews())
  call win_gotoid(winid)
  wincmd L
  let tab = plum#layout#Tab()
  let wincol_idx = len(tab.layout.children) - 1
  let win = tab.layout.children[wincol_idx].children[0]
  if win.width >= win.require_width || len(tab.layout.children) == 1
    call plum#layout#PutViews(views)
    call win_gotoid(winid)
    return
  endif
  " increasing in height satisfaction
  let order = plum#layout#ColumnOrder(tab)
  let col_idx = order[-1][-1]
  if col_idx == wincol_idx
    let col_idx = order[-2][-1]
  endif
  let col = tab.layout.children[col_idx]
  let is_term = win.terminal_status != ''
  let relative_loc = is_term ? 'BELOW' : 'ABOVE'
  let dest = is_term ? col.children[-1] : col.children[0]
  call plum#layout#SplitMove(win, dest, relative_loc)
  exe plum#layout#ResizeCmd()
  call plum#layout#PutViews(views)
  call win_gotoid(winid)
endfunction

function! plum#layout#SplitMove(source, dest, ...)
  let [source, dest, relative_loc] = [a:source, a:dest, get(a:000, 0, 'ABOVE')]
  if source.type != 'leaf' || dest.type != 'leaf'
    throw 'ERR1: TODO(larioj): implement support for nested windows'
  endif
  let opt = {'rightbelow': tolower(relative_loc[0]) == 'b'}
  call win_splitmove(source.id, dest.id, opt)
endfunction

function! plum#layout#GetViews()
  let curid = win_getid()
  let views = {}
  for nr in range(1, winnr('$'))
    let id = win_getid(nr)
    call win_gotoid(id)
    let views[id] = winsaveview()
  endfor
  call win_gotoid(curid)
  return views
endfunction

function! plum#layout#PutViews(views)
  let views = a:views
  let curid = win_getid()
  for nr in range(1, winnr('$'))
    let id = win_getid(nr)
    if has_key(views, id)
      call win_gotoid(id)
      let view = copy(views[id])
      let height = winheight(id)
      let botline = view.topline + height - 3
      let view.lnum = max([view.topline, min([botline, view.lnum])])
      call winrestview(view)
    endif
  endfor
  call win_gotoid(curid)
endfunction

function! plum#layout#Open(...)
  let LoadFn = get(a:000, 0, {-> v:none})
  let views = plum#layout#GetViews()
  botright vsplit
  call LoadFn()
  call plum#layout#Move(win_getid(), views)
endfunction

function! plum#layout#MaxId()
  let max = 0
  for nr in range(1, winnr('$'))
    let id = win_getid(nr)
    let max = max([max, id])
  endfor
  return max
endfunction

function! plum#layout#Close()
  let views = plum#layout#GetViews()
  let winid = win_getid()
  let w:plum_history = get(w:, 'plum_history', [])
  if len(w:plum_history)
    unlet views[winid]
    let nr = remove(w:plum_history, -1)
    exe 'buffer ' . nr
    exe plum#layout#ResizeCmd()
    call plum#layout#PutViews(views)
    return
  endif
  quit
  let dest = plum#layout#MaxId()
  call plum#layout#Move(dest, views)
endfunction

function! plum#layout#Delete()
  let views = plum#layout#GetViews()
  let winid = win_getid()
  let bufnr = bufnr()
  let w:plum_history = get(w:, 'plum_history', [])
  if len(w:plum_history)
    unlet views[winid]
    let nr = remove(w:plum_history, -1)
    exe 'buffer ' . nr
    exe bufnr . ' bdelete!'
    exe plum#layout#ResizeCmd()
    call plum#layout#PutViews(views)
    return
  endif
  bdelete!
  let dest = plum#layout#MaxId()
  call plum#layout#Move(dest, views)
endfunction

function! plum#layout#Edit(...)
  let LoadFn = get(a:000, 0, {-> v:none})
  let w:plum_history = get(w:, 'plum_history', [])
  if &bufhidden != 'wipe' && &bufhidden != 'delete'
    call add(w:plum_history, bufnr())
  endif
  call LoadFn()
  let views = plum#layout#GetViews()
  exe plum#layout#ResizeCmd()
  unlet views[win_getid()]
  call plum#layout#PutViews(views)
endfunction
