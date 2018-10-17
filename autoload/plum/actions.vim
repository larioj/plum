function! plum#actions#Exec(ctx)
  execute a:ctx.match
endfunction

function! plum#actions#DeleteIfEmpty(job, status)
  call term_wait(expand('%'), 1000)
  call term_wait(expand('%'), 1000)
  call term_wait(expand('%'), 1000)
  call term_wait(expand('%'), 1000)
  let l:contents = plum#util#Trim(
        \ plum#extensions#GetBufferContents())
  if l:contents ==# '' && a:status ==# 0
    q
  elseif &buftype ==# 'terminal'
    set modifiable
    setlocal buftype=nofile
  endif
endfunction

function! plum#actions#Term(ctx)
  if !has('terminal')
    return 1 " fail if vim does not have terminal
  endif
  let l:curdir = getcwd()
  let l:options =
        \ { 'exit_cb'   : 'plum#actions#DeleteIfEmpty'
        \ , 'term_name' : a:ctx.match
        \ , 'cwd'       : l:curdir
        \ }
  let l:wins = plum#extensions#WindowByName()
  if has_key(l:wins, a:ctx.match)
    call plum#extensions#SwitchToWindow(l:wins[a:ctx.match])
    let l:options.curwin = 1
  endif
  let l:command = ['/bin/sh', '-ic', a:ctx.match]
  call term_start(l:command, l:options)
endfunction

function! plum#actions#Shell(ctx)
  call plum#actions#Scratch(a:ctx)
  execute '$read ! '. a:ctx.match
endfunction

function! plum#actions#Scratch(ctx)
  if a:ctx.shift
    enew
  else
    new
  endif
  let l:dir = get(a:ctx, 'dir', '')
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  let b:plum_basedir = l:dir
endfunction

function! plum#actions#File(ctx)
  if a:ctx.shift
    execute "edit " . a:ctx.match
  else
    execute "below split " . a:ctx.match
  endif
endfunction

function! plum#actions#Dir(ctx)
  let l:path = a:ctx['match']
  let a:ctx['match'] = 'find ' . l:path . ' -maxdepth 1 | sort'
  call plum#actions#Shell(a:ctx)
endfunction
