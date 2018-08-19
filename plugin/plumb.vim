nnoremap <RightMouse> <LeftMouse>:call plumb#core#Plumb({ 'mode' : 'n', })
"vnoremap <RightMouse> :<c-u>call Plumb({'mode': visualmode(),})
"inoremap <RightMouse> :<c-u>call Plumb({'mode': 'i'         ,})
"nnoremap <S-RightMouse> :<c-u>call Plumb({'mode': 'n'         , 'shift': 1,})
"vnoremap <S-RightMouse> :<c-u>call Plumb({'mode': visualmode(), 'shift': 1,})
"inoremap <S-RightMouse> :<c-u>call Plumb({'mode': 'i'         , 'shift': 1,})

let g:Plumb_DebugEnabled = get(g:, 'Plumb_DebugEnabled', 1)
let b:Plumb_DebugEnabled = get(b:, 'Plumb_DebugEnabled', 1)

let g:Plumb_Actions = get(g:, 'Plumb_Actions', [
      \ { 'name' : 'Files'
      \ , 'matcher' : function('plumb#matchers#File')
      \ , 'action' : function('plumb#actions#File')
      \ , }])
let b:Plumb_Actions = get(b:, 'Plumb_Actions', [])
