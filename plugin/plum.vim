let g:Plum_DebugEnabled = get(g:, 'Plum_DebugEnabled', 0)
let b:Plum_DebugEnabled = get(b:, 'Plum_DebugEnabled', 0)

let g:Plum_Actions = get(g:, 'Plum_Actions', plum#defaults#DefaultActions())
let b:Plum_Actions = get(b:, 'Plum_Actions', [])

function! Plum_SetLeftMouseBindings()
  call plum#defaults#SetLeftMouseBindings()
endfunction

function! Plum_InsertAction(index, name, matcher, action)
  call insert(g:Plum_Actions, {
        \ 'name' : name, 'matcher' : matcher, 'action' : action })
endfunction
