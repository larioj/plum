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
  if !has('terminal')
    echom 'This action requries vim +terminal'
    return
  endif
  let exp = a:exp
  let windows = {}
  for i in range(1, winnr('$'))
    let windows[bufname(winbufnr(i))] = i
  endfor
  if has_key(windows, exp)
    execute windows[exp] . 'wincmd w'
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
  let options =
        \ { 'exit_cb': { _, status -> s:DeleteIfEmpty(status) }
        \ , 'term_name': exp
        \ , 'curwin': 1
        \ , 'term_finish': 'open'
        \ }
  let command = ['/bin/sh', '-ic', exp]
  call term_start(command, options)
endfunction

function! s:DeleteIfEmpty(status)
  call term_wait('', 100)
  if trim(join(getline(1, '$'), "\n")) ==# '' && a:status ==# 0
    close
  endif
endfunction
