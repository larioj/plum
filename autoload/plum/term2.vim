function! s:CloseIfEmpty(winid, status)
  let [winid, status] = [a:winid, a:status]
  let after_close = get(g:, 'plum_after_close', '')
  let bufnr = winbufnr(winid)
  call term_wait(bufnr, 1000)
  let bufcontent = trim(join(getbufline(bufnr, 1, '$'), "\n"))
  if status || len(bufcontent)
    return
  endif
  exe bufnr . ' bwipe!'
  exe after_close
endfunction

function! plum#term2#Eval(exp)
  let exp = a:exp
  let open_cmd = get(g:, 'plum_open_cmd', 'split')
  if !has('terminal')
    echom 'This action requries vim +terminal'
    return
  endif
  let cwd = getcwd()
  let $vimfile = expand('%')
  let destid = 0
  for winnr in range(1, winnr('$'))
    let name = bufname(winbufnr(winnr))
    if name ==# exp
      let destid = win_getid(winnr)
    endif
  endfor
  if destid && term_getstatus(winbufnr(destid)) == 'finished'
    call win_gotoid(destid)
  else
    execute open_cmd
  endif
  let winid = win_getid()
  let options =
        \ { 'exit_cb': { _, status -> s:CloseIfEmpty(winid, status) }
        \ , 'term_name': exp
        \ , 'curwin': 1
        \ , 'term_finish': 'open'
        \ , 'cwd': cwd
        \ }
  let command = ['/bin/bash', '-ic', exp]
  call term_start(command, options)
endfunction

function! plum#term2#Term()
  return [ { c, _ -> plum#term#Extract() }
        \, { c, _ -> plum#term2#Eval(c) } ]
endfunction
