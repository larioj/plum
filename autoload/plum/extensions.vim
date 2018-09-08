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
