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
        \ 'name' : 'DefaultFileAction',
        \ 'matcher' : function('plum#matchers#File'),
        \ 'action' : function('plum#actions#File'),
        \ }
endfunction

function! plum#defaults#DefaultDirectoryAction()
  return {
        \ 'name' : 'DefaultDirectoryAction',
        \ 'matcher' : function('plum#matchers#Dir'),
        \ 'action' : function('plum#actions#Dir'),
        \ }
endfunction

function! plum#defaults#DefaultTerminalAction()
  return {
        \ 'name' : 'DefaultTerminalAction',
        \ 'matcher' : function('plum#matchers#BashCommand'),
        \ 'action' : function('plum#actions#Term'),
        \ }
endfunction

" Automatically closes empty windows
" Not default because it will cause seg fault
" on certain vim versions
function! plum#defaults#SmartTerminalAction()
  return {
        \ 'name' : 'SmartTerminalAction',
        \ 'matcher' : function('plum#matchers#BashCommand'),
        \ 'action' : function('plum#actions#SmartTerm'),
        \ }
endfunction

function! plum#defaults#DefaultVimCommandAction()
  return {
        \ 'name' : 'DefaultVimCommandAction',
        \ 'matcher' : function('plum#matchers#TrimmedLineStartsWithColonSpace'),
        \ 'action' : function('plum#actions#Exec'),
        \ }
endfunction

function! plum#defaults#DefaultActions()
  return [ plum#defaults#DefaultFileAction()
        \, plum#defaults#DefaultDirectoryAction()
        \, plum#defaults#DefaultVimCommandAction()
        \, plum#defaults#DefaultTerminalAction()
        \]
endfunction
