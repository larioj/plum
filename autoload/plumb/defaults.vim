function! plumb#defaults#SetLeftMouseBindings()
  nnoremap <RightMouse> <LeftMouse>:call plumb#core#Plumb({'mode' : 'n',})<cr>
  vnoremap <RightMouse> <LeftMouse>:<c-u>call plumb#core#Plumb({'mode': visualmode(),})<cr>
  inoremap <RightMouse> <LeftMouse><esc>:call plumb#core#Plumb({'mode': 'i',})<cr>
  nnoremap <S-RightMouse> <LeftMouse>:call plumb#core#Plumb({'mode': 'n', 'shift': 1,})<cr>
  vnoremap <S-RightMouse> <LeftMouse>:<c-u>call plumb#core#Plumb({'mode': visualmode(), 'shift': 1,})<cr>
  inoremap <S-RightMouse> <LeftMouse><esc>:call plumb#core#Plumb({'mode': 'i', 'shift': 1,})<cr>
endfunction

function! plumb#defaults#DefaultFileAction()
  return {
        \ 'name' : 'Default Files Action',
        \ 'matcher' : function('plumb#matchers#File'),
        \ 'action' : function('plumb#actions#File'),
        \ }
endfunction

function! plumb#defaults#DefaultDirAction()
  return {
        \ 'name' : 'Default Directory Action',
        \ 'matcher' : function('plumb#matchers#Dir'),
        \ 'action' : function('plumb#actions#Dir'),
        \ }
endfunction

function! plumb#defaults#DefaultActions()
  return [ plumb#defaults#DefaultFileAction()
        \, plumb#defaults#DefaultDirAction()
        \]
endfunction
