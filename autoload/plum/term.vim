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

function! plum#term#Act(exp)
  let exp = a:exp
  if !has('terminal')
    echom 'This action requries vim +terminal'
    return
  endif
  let cwd = getcwd()
  let views = plum#layout#GetViews()
  let $vimfile = expand('%')
  let destid = 0
  for winnr in range(1, winnr('$'))
    let name = bufname(winbufnr(winnr))
    if name ==# exp
      let destid = win_getid(winnr)
    endif
  endfor
  if destid && term_getstatus(winbufnr(destid)) == 'finished'
    unlet views[destid]
    call win_gotoid(destid)
    if winheight(0) < 2
      resize 2
    endif
  else
    botright vsplit
  endif
  let winid = win_getid()
  let options =
        \ { 'exit_cb': { _, status -> s:DeleteIfEmpty(winid, status) }
        \ , 'term_name': exp
        \ , 'curwin': 1
        \ , 'term_finish': 'open'
        \ , 'cwd': cwd
        \ }
  let command = ['/bin/bash', '-ic', exp]
  call term_start(command, options)
  call plum#layout#Move(win_getid(), views)
endfunction

function! s:SetBottomLine(winid)
  let winid = a:winid
  let winlist = getwininfo(winid)
  if len(winlist)
    let win = winlist[0]
    let buf = getbufinfo(win.bufnr)[0]
    let topline = max([1, buf.linecount - win.height + 1])
    let lnum = topline
    let views = {}
    let views[winid] = {'topline': topline, 'lnum': lnum }
    call plum#layout#PutViews(views)
  endif
endfunction

function! s:DeleteIfEmpty(winid, status)
  let [winid, status] = [a:winid, a:status]
  let bufnr = winbufnr(winid)
  call term_wait(bufnr, 1000)
  let bufcontent = trim(join(getbufline(bufnr, 1, '$'), "\n"))
  if status || len(bufcontent)
    let views = plum#layout#GetViews()
    exe plum#layout#ResizeCmd()
    call plum#layout#PutViews(views)
    call s:SetBottomLine(winid)
    return
  endif
  let views = plum#layout#GetViews()
  exe bufnr . ' bwipe!'
  exe plum#layout#ResizeCmd()
  call plum#layout#PutViews(views)
endfunction
