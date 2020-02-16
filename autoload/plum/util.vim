function! plum#util#visual()
  if get(b:, 'plum_trigger_mode', '') !=# 'v'
    return ''
  endif
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

function! plum#util#visualorline()
  let r = plum#util#visual()
  if r ==# ''
    let r = getline('.')
  endif
  return r
endfunction

function! plum#util#path()
  let old = &isfname
  set isfname+=58 " allow ':'
  let p = expand(expand('<cfile>'))
  let &isfname = old
  return p
endfunction
