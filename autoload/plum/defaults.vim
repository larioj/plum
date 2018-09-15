function! plum#defaults#SetLeftMouseBindings()
  nnoremap <RightMouse> <LeftMouse>:call plum#core#Plum({'mode' : 'n',})<cr>
  vnoremap <RightMouse> <LeftMouse>:<c-u>call plum#core#Plum({'mode': visualmode(),})<cr>
  inoremap <RightMouse> <LeftMouse><esc>:call plum#core#Plum({'mode': 'i',})<cr>
  nnoremap <S-RightMouse> <LeftMouse>:call plum#core#Plum({'mode': 'n', 'shift': 1,})<cr>
  vnoremap <S-RightMouse> <LeftMouse>:<c-u>call plum#core#Plum({'mode': visualmode(), 'shift': 1,})<cr>
  inoremap <S-RightMouse> <LeftMouse><esc>:call plum#core#Plum({'mode': 'i', 'shift': 1,})<cr>
endfunction

function! plum#defaults#DefaultFileAction()
  return {
        \ 'name' : 'Default Files Action',
        \ 'matcher' : function('plum#matchers#File'),
        \ 'action' : function('plum#actions#File'),
        \ }
endfunction

function! plum#defaults#DefaultDirAction()
  return {
        \ 'name' : 'Default Directory Action',
        \ 'matcher' : function('plum#matchers#Dir'),
        \ 'action' : function('plum#actions#Dir'),
        \ }
endfunction

function! plum#defaults#DefaultTermAction()
  return {
        \ 'name' : 'Default Term Action',
        \ 'matcher' : function('plum#matchers#BashCommand'),
        \ 'action' : function('plum#actions#Term'),
        \ }
endfunction

function! plum#defaults#DefaultExecAction()
  return {
        \ 'name' : 'Default Exec Action',
        \ 'matcher' : function('plum#matchers#TrimmedLineStartsWithColonSpace'),
        \ 'action' : function('plum#actions#Exec'),
        \ }
endfunction

function! plum#defaults#DefaultActions()
  return [ plum#defaults#DefaultFileAction()
        \, plum#defaults#DefaultDirAction()
        \, plum#defaults#DefaultExecAction()
        \, plum#defaults#DefaultTermAction()
        \]
endfunction
