function! plum#term#Terminal()
  return plum#CreateAction(
        \ 'plum#term#Terminal'
        \ function('plum#term#IsTerminalCommand')
        \ function('plum#term#ApplyTerminalCommand'))
endfunction

function! plum#term#SmartTerminal()
  return plum#CreateAction(
        \ 'plum#term#Terminal'
        \ function('plum#term#IsTerminalCommand')
        \ function('plum#term#ApplySmartTerminalCommand'))
endfunction

function! plum#term#IsTerminalCommand(context)
  let context = a:context
  let content = plum#util#Trim(context.content)
  if strpart(content, 0, 2) !=# '$ '
    return 0
  endif
  " capture escaped line endings
  if context.mode ==# 'n' || context.mode ==# 'i'
    let lnum = line('.')
    let curline = content
    let lines = [curline]
    while curline[-1:] ==# '\'
      let lnum += 1
      let curline = getline(lnum)
      let lines = lines + [curline]
    endwhile
    let content = join(lines, "\n")
  endif
  let context.match = strpart(content, 2)
  return 1
endfunction

function! plum#term#ApplyTerminalCommand(context)
  if !has('terminal')
    return 'this version of vim does not support terminal'
  endif
  let context = a:context
  let options = { 'curwin' : context.shift }
  let command = ['/bin/sh', '-ic', context.match]
  call term_start(command, options)
endfunction

function! plum#term#ApplySmartTerminalCommand(context)
  if !has('terminal')
    return 'this version of vim does not support terminal'
  endif
  let context = a:context
  let options =
        \ { 'exit_cb'   : function('plum#term#DeleteIfEmpty')
        \ , 'term_name' : context.match
        \ }
  let reuse_open_window = !context.shift
  if reuse_open_window
    let windows = plum#extensions#WindowByName()
    if has_key(windows, context.match)
      call plum#extensions#SwitchToWindow(windows[context.match])
      let options.curwin = 1
    endif
  endif
  let command = ['/bin/sh', '-ic', context.match]
  call term_start(command, options)
endfunction

function! plum#term#DeleteIfEmpty(job, status)
  call term_wait(expand('%'), 1000)
  call term_wait(expand('%'), 1000)
  call term_wait(expand('%'), 1000)
  call term_wait(expand('%'), 1000)
  let l:contents = plum#util#Trim(
        \ plum#extensions#GetBufferContents())
  if l:contents ==# '' && a:status ==# 0
    quit
  endif
endfunction
