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
    if len(state[i]) < len(state[min])
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
