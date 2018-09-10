function! plum#actions#Exec(ctx)
  execute a:ctx.match
endfunction

function! plum#actions#DeleteIfEmpty(job, status)
  call term_wait(expand('%'))
  set modifiable
  setlocal buftype=nofile
  let l:contents = plum#util#Trim(
        \ plum#extensions#GetBufferContents())
  if l:contents ==# '' && a:status ==# 0
    q
  endif
endfunction

function! plum#actions#Term(ctx)
  let l:callback = {'exit_cb': 'plum#actions#DeleteIfEmpty'}
  let l:command = ['/bin/sh', '-ic', a:ctx.match]
  call term_start(l:command, l:callback)
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
