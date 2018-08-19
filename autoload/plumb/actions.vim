function! plumb#actions#Exec(ctx)
  execute a:ctx.match
endfunction

function! plumb#actions#Term(ctx)
  execute 'terminal ' . a:ctx.match
endfunction

function! plumb#actions#Shell(ctx)
  call plumb#actions#Scratch(a:ctx)
  execute '$read ! '. a:ctx.match
endfunction

function! plumb#actions#Scratch(ctx)
  if a:ctx.shift
    enew
  else
    new
  endif
  let l:dir = get(a:ctx, 'dir', '')
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  let b:plumb_basedir = l:dir
endfunction

function! plumb#actions#File(ctx)
  if a:ctx.shift
    execute "edit " . a:ctx.match
  else
    execute "below split " . a:ctx.match
  endif
endfunction

function! plumb#actions#Dir(ctx)
  let l:path = a:ctx['match']
  let a:ctx['match'] = 'find ' . l:path . ' -maxdepth 1 | sort'
  call plumb#actions#Shell(a:ctx)
endfunction
