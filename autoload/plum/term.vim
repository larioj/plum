function! plum#term#SmartTerminal()
  return plum#term#Terminal()
endfunction

function! plum#term#Terminal()
  return [ { c, _ -> plum#term#Extract() }
        \, { c, _ -> plum#term#Act(c) } ]
endfunction

function! plum#term#ReadEscapeTerminatedLines(start)
  let start = a:start
  let end = start
  let lines = [getline(end)]
  while lines[-1][-1:] ==# '\' && end < line('$')
    let end = end + 1
    call add(lines, getline(end))
  endwhile
  return [end + 1, lines]
endfunction

function! plum#term#ReadHeredocBody(start, end_token)
  let end_token = a:end_token
  let start = a:start
  let end = start
  let lines = [getline(end)]
  while end < line('$') && lines[-1] !~# (end_token . '$')
    let end = end + 1
    call add(lines, getline(end))
  endwhile
  return [end + 1, lines]
endfunction

function! plum#term#ReadBash()
  let start = line('.')
  let [end, cmd] = plum#term#ReadEscapeTerminatedLines(start)
  if  cmd[-1] =~# '<<EOF' || cmd[-1] =~# "<<'EOF'"
    let [end, body] = plum#term#ReadHeredocBody(end, 'EOF')
    let cmd = cmd + body
  endif
  return cmd
endfunction

function! plum#term#ReadActiveBash()
  if plum#util#HasVSel()
    return plum#util#ReadVSel()
  endif
  return plum#term#ReadBash()
endfunction

function! plum#term#Extract()
  let is_comment = synIDattr(synIDtrans(synID(line("."), col("$")-1, 1)), "name") ==# 'Comment'
  let cmd = plum#term#ReadActiveBash()
  let indent = 0
  while indent < len(cmd[0]) && strpart(cmd[0], indent, 2) !=# '$ '
    let indent = indent + 1
  endwhile
  let prefix = strpart(cmd[0], 0, indent)
  if indent >= len(cmd[0]) || 
        \ (is_comment && len(prefix) && prefix !~# '\v^\W*\s+$') || 
        \ (!is_comment && len(trim(prefix)))
    return ['', v:false]
  endif
  if is_comment
    call map(cmd, { _, l -> l[indent:] })
    let indent = 0
  endif
  let end = 0
  while end < len(cmd) && cmd[end][-1:] ==# '\'
    let end = end + 1
  endwhile
  let first_line = cmd[0:end]
  let rest = cmd[end+1:]
  call map(first_line, { _, l -> trim(l[-1:] ==# '\' ? strpart(l, 0, len(l) - 1) : l) })
  let first_line = join(first_line, ' ')
  call map(rest, { _, l -> l[indent:] })
  return [join([first_line] + rest, "\n")[2:], v:true]
endfunction

function! plum#term#NextWindow()
  let last = winnr()
  " move right
  wincmd l
  " if at rightmost, move leftmost
  if winnr() ==# last
    200 wincmd h
  endif
  "move bottommost
  200 wincmd j
endfunction

function! plum#term#Act(exp)
  let cwd = getcwd()
  let exp = a:exp
  if !has('terminal')
    echom 'This action requries vim +terminal'
    return
  endif
  "set vimfile env var
  let $vimfile = expand('%')
  let windows = {}
  for i in range(1, winnr('$'))
    let windows[bufname(winbufnr(i))] = i
  endfor
  if has_key(windows, exp) && s:is_finised(windows[exp])
    execute windows[exp] . 'wincmd w'
    enew
  else
    call plum#win#Create(v:false)
    execute 'lcd ' . cwd
  endif
  let buf = bufnr()
  let win = win_getid()
  echom 'created buf:' . buf . ' win:' . win
  let options =
        \ { 'exit_cb': { _, status -> s:DeleteIfEmpty(buf, win, status) }
        \ , 'term_name': exp
        \ , 'curwin': 1
        \ , 'term_finish': 'open'
        \ , 'cwd': cwd
        \ }
  let command = ['/bin/sh', '-ic', exp]
  call term_start(command, options)
endfunction

function! s:is_finised(win)
  let buf = winbufnr(a:win)
  return term_getstatus(buf) == 'finished'
endfunction

function! s:DeleteIfEmpty(buf, win, status)
  let [buf, win, status] = [a:buf, a:win, a:status]
  call term_wait(buf, 1000)
  let lines = []
  for i in range(1, line('$', win))
    call add(lines, term_getline(buf, i))
  endfor
  echom 'checking buf:' . buf . ' win:' . win
  if trim(join(lines, "\n")) ==# '' && status ==# 0
    echom 'deleting buf:' . buf . ' win:' . win
    exe buf 'bwipe!'
  endif
endfunction
