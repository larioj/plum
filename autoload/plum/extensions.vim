function! plum#extensions#GetVisualSelection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function! plum#extensions#GetPath()
  return expand(expand("<cfile>"))
endfunction

function! plum#extensions#GetLine()
  return getline(".")
endfunction

function! plum#extensions#GetBufferContents()
  return join(getline(1, '$'), "\n")
endfunction

function! plum#extensions#WindowList()
  return map(range(1, winnr('$')), '[v:val, bufname(winbufnr(v:val))]')
endfunction

function! plum#extensions#WindowByName()
  let l:r = {}
  for pair in plum#extensions#WindowList()
    let l:r[pair[1]] = pair[0]
  endfor
  return l:r
endfunction

function! plum#extensions#SwitchToWindow(idx)
  execute a:idx . 'wincmd w'
endfunction

function! plum#extensions#NvimTerminalWindowList()
  let windows = plum#extensions#WindowList()
  let term_windows = []
  for pair in windows
    let term_prefix = 'term://'
    let name = pair[1]
    if strpart(name, 0, len(term_prefix)) ==# term_prefix
      let term_windows = [pair] + term_windows
    endif
  endfor
  return term_windows
endfunction

function! plum#extensions#NvimCommandToWindowNumber()
  let term_prefix = 'term://'
  let terminal_windows = plum#extensions#NvimTerminalWindowList()
  let dict = {}
  for pair in terminal_windows
    let number = pair[0]
    let name = pair[1]
    let command = s:DropUntilColonInclusive(strpart(name, len(term_prefix)))
    let dict[command] = number
  endfor
  return dict
endfunction

function! s:DropUntilColonInclusive(str)
  let res = a:str
  while res != '' && res[0] !=# ':'
    let res = strpart(res, 1)
  endwhile
  return strpart(res, 1)
endfunction
