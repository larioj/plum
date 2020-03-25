function! plum#util#ReadVSel()
  if get(b:, 'plum_trigger_mode', '') !=# 'v'
    return []
  endif
  let [line_start, column_start] = getpos("'<")[1:2]
  let [line_end, column_end] = getpos("'>")[1:2]
  let lines = getline(line_start, line_end)
  if len(lines) == 0
      return []
  endif
  let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
  let lines[0] = lines[0][column_start - 1:]
  return lines
endfunction

function! plum#util#ReadActiveContent()
  if plum#util#HasVSel()
    return join(plum#util#ReadVSel(), "\n")
  endif
  return getline('.')
endfunction

function! plum#util#path()
  let old = &isfname
  set isfname+=58 " allow ':'
  let p = expand(expand('<cfile>'))
  let &isfname = old
  return p
endfunction

function! plum#util#HasVSel()
  let m = get(b:, 'plum_trigger_mode', '')
  return m ==# 'v'
endfunction
