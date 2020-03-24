function! plum#term#SmartTerminal()
  return plum#term#Terminal()
endfunction

function! plum#term#Terminal()
  return [ { c, _ -> plum#term#Extract() }
        \, { c, _ -> plum#term#Act(c) } ]
endfunction

function! plum#term#Extract()
  let content = plum#util#visualorline()

  " get indentation
  let size = 0
  let indentation = ''
  while trim(indentation) ==# ''
    let size += 1
    let indentation = strpart(content, 0, size)
  endwhile
  let size -= 1
  let indentation = strpart(indentation, 0, size)

  " check if matches pattern
  let content = strpart(content, size)
  if content[0:1] !=# '$ '
    return ['', v:false]
  endif

  let lnum = line('.')
  let lines = [content[2:]]

  " get multiline command
  while lines[-1][-1:] ==# '\'
    let lines[-1] = trim(strpart(lines[-1], 0, len(lines[-1]) - 1))
    let lnum += 1
    let lines = lines + [getline(lnum)]
    if lines[-1] =~# ('^' . indentation)
      let lines[-1] = trim(strpart(lines[-1], size))
    endif
  endwhile
  let lines = [join(lines, ' ')]

  " get heredoc
  if  lines[-1] =~# '<<EOF' || lines[-1] =~# "<<'EOF'"
    while trim(lines[-1]) !=# 'EOF' && lnum < line('$')
      let lnum += 1
      let lines = lines + [getline(lnum)]
      if lines[-1] =~# ('^' . indentation)
        let lines[-1] = strpart(lines[-1], size)
      else " malformed heredoc
        return ['', v:false]
      endif
    endwhile
  endif

  return [join(lines, "\n"), v:true]
endfunction

function! plum#term#Act(exp)
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
    let last = 0
    let cur = winnr()
    while last !=# cur
      wincmd j
      let last = cur
      let cur = winnr()
    endwhile
    belowright new
  endif
  let buf = bufnr()
  let win = win_getid()
  echom 'created buf:' . buf . ' win:' . win
  let options =
        \ { 'exit_cb': { _, status -> s:DeleteIfEmpty(buf, win, status) }
        \ , 'term_name': exp
        \ , 'curwin': 1
        \ , 'term_finish': 'open'
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
