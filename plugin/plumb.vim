let g:Plumb_DebugEnabled = get(g:, 'Plumb_DebugEnabled', 1)
let b:Plumb_DebugEnabled = get(b:, 'Plumb_DebugEnabled', 1)

let g:Plumb_Actions = get(g:, 'Plumb_Actions', plumb#defaults#DefaultActions())
let b:Plumb_Actions = get(b:, 'Plumb_Actions', [])

function! Plumb_SetLeftMouseBindings()
  call plumb#defaults#SetLeftMouseBindings()
endfunction

function! Plumb_InsertAction(index, name, matcher, action)
  call insert(g:Plumb_Actions, {
        \ 'name' : name, 'matcher' : matcher, 'action' : action })
endfunction
