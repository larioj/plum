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
  let win = {}
  let win.id = winid
  let win.view = { 'topline' : wininfo.topline }
  let win.height = wininfo.height
  let win.require_height = get(w:, 'plum_require_height', 1)
  let win.want_height = get(w:, 'plum_want_height', min([25, bufinfo.linecount]))
  let win.enough_height = get(w:, 'plum_enough_height', 
        \ modifiable ? max([15, bufinfo.linecount]) : bufinfo.linecount)
  let win.terminal_status = get(w:, 'plum_terminal_status',
        \ term_getstatus(bufnr))
  let win.width = wininfo.width
  let win.require_width = 90
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

function! plum#layout#FindParent(parent, index, layout, id)
  let [parent, index, layout, id] = [a:parent, a:index, a:layout, a:id]
  if layout[0] == 'leaf'
    return [layout[1] == id, parent, index]
  endif
  for i in range(len(layout[1]))
    let child = layout[1][i]
    let [is_found, p, j] = plum#layout#FindParent(layout, i, child, id)
    if is_found
      return [is_found, p, j]
    endif
  endfor
  return [v:false, parent, index]
endfunction

function! plum#layout#Delete(...)
  let id = get(a:000, 0, win_getid())
  let root = get(a:000, 1, plum#layout#Tab())
  let original_layout = deepcopy(root.original_layout)
  if original_layout[0] == 'leaf'
    return [v:false, v:none]
  endif
  let [is_found, parent, index] = 
        \ plum#layout#FindParent(v:none, -1, original_layout, id)
  if is_found
    call remove(parent[1], index)
    let layout = plum#layout#Layout(original_layout)
    let WinFn = {id -> root.leafs[id]}
    let tab = plum#layout#Tab(layout, WinFn)
    let tab.layout.height = root.layout.height
    let tab.layout.width = root.layout.width
    call plum#layout#Resize(tab)
    return [v:true, tab]
  endif
  return [v:false, v:none]
endfunction

function! s:Descend(node)
  let node = a:node
  if node.type == 'leaf'
    return node
  endif
  return s:Descend(node.children[0])
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

function! plum#layout#LeafOrder(...)
  let top = get(a:000, 0, plum#layout#Tab())
  let files = []
  let terminals = []
  for node in plum#layout#Traversal(top)
    if node.type == 'leaf'
      if node.terminal_status == ''
        call add(files, node)
      else
        call add(terminals, node)
      endif
    endif
  endfor
  return [files, terminals]
endfunction

function! plum#layout#MoveCmd(...)
  let top = get(a:000, 0, plum#layout#Tab())
  let id = get(a:000, 1, win_getid())
  if len(top.leafs) == 1
    return ''
  endif
  let [success, without_id] = plum#layout#Delete(id, top)
  if !success
    return ''
  endif
  let leaf = top.leafs[id]
  if leaf.require_width + without_id.layout.require_width < top.layout.width
    return 'wincmd L'
  endif
  let order = plum#layout#ColumnOrder(without_id)
  let active_col = order[-1][-1]
  let [files, terminals] = plum#layout#LeafOrder(
        \ without_id.layout.children[active_col])
  let is_term = leaf.terminal_status != ''
  let dest = is_term ? (files + terminals)[-1] : (files + terminals)[0]
  let opt = '{"rightbelow" : ' . is_term . '}'
  let cmd = 'call win_splitmove(' . id . ','. dest.id . ',' . opt . ')'
  return cmd
endfunction

function! plum#layout#ResetViews(...)
  let root = get(a:000, 0, plum#layout#Tab())
  let skip_id = get(a:000, 1, -1)
  let curview = winsaveview()
  let curid = win_getid()
  for node in plum#layout#Traversal(root)
    if node.type == 'leaf' && node.id != skip_id
      "echo 'reset ' . node.id . ' ' . node.view.topline
      call win_gotoid(node.id)
      call execute(node.view.topline + 2)
      call winrestview(node.view)
    endif
    if node.type == 'leaf' && node.id == skip_id
      "echo 'skiping ' . skip_id
    endif
  endfor
  call win_gotoid(curid)
  call winrestview(curview)
endfunction

function! plum#layout#Open(...)
  let LoadFn = get(a:000, 0, {-> v:none})
  let original = plum#layout#Tab()
  vsplit
  call LoadFn()
  exe plum#layout#MoveCmd()
  exe plum#layout#ResizeCmd()
  call plum#layout#ResetViews(original)
endfunction

function! plum#layout#Edit(...)
  let LoadFn = get(a:000, 0, {-> v:none})
  let original = plum#layout#Tab()
  let w:plum_history = get(w:, 'plum_history', [])
  if &bufhidden != 'wipe' && &bufhidden != 'delete'
    call add(w:plum_history, bufnr())
  endif
  call LoadFn()
  exe plum#layout#ResizeCmd()
  call plum#layout#ResetViews(original)
endfunction

function! plum#layout#OpenTerm()
  let original = plum#layout#Tab()
  vsplit
  let w:plum_terminal_status = 'not_started'
  exe plum#layout#MoveCmd()
  let w:plum_require_height = 8
  let w:plum_want_height = 8
  let w:plum_enough_height = 8
  exe plum#layout#ResizeCmd()
  call plum#layout#ResetViews(original)
  unlet w:plum_terminal_status
  unlet w:plum_require_height
  unlet w:plum_want_height
  unlet w:plum_enough_height
endfunction

function! plum#layout#Close()
  let original = plum#layout#Tab()
  let w:plum_history = get(w:, 'plum_history', [])
  if len(w:plum_history)
    let nr = remove(w:plum_history, -1)
    exe 'buffer ' . nr
    exe plum#layout#ResizeCmd()
    call plum#layout#ResetViews(original, -1)
    return
  endif
  let skip_id = win_getid()
  wincmd L
  quit
  exe plum#layout#ResizeCmd()
  let tab = plum#layout#Tab()
  let order = plum#layout#ColumnOrder(tab)
  let active_col = order[0][-1]
  let [files, terminals] = plum#layout#LeafOrder(tab.layout.children[active_col])
  let dest = len(terminals) ? terminals[-1] : files[0]
  call win_gotoid(dest.id)
  if len(files) + len(terminals) == 1 ||
        \ (len(tab.leafs) == len(tab.layout.children) &&
        \    tab.leafs[dest.id].width >= tab.leafs[dest.id].require_width)
    call plum#layout#ResetViews(original, skip_id)
    return
  endif
  call win_gotoid(dest.id)
  exe plum#layout#MoveCmd(tab, dest.id)
  exe plum#layout#ResizeCmd()
  call plum#layout#ResetViews(original, skip_id)
endfunction
