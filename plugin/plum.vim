let g:Plum_DebugEnabled = get(g:, 'Plum_DebugEnabled', 0)
let b:Plum_DebugEnabled = get(b:, 'Plum_DebugEnabled', 0)

let g:Plum_Actions = get(g:, 'Plum_Actions', plum#defaults#DefaultActions())
let b:Plum_Actions = get(b:, 'Plum_Actions', [])

function! Plum_SetRightMouseBindings()
  call plum#defaults#SetRightMouseBindings()
endfunction

function! Plum_CreateAction(name, matcher, action)
  return {
        \ 'name': a:name,
        \ 'matcher' : plum#util#Fun(a:matcher),
        \ 'action' : plum#util#Fun(a:action),
        \ }
endfunction

function! Plum_AppendAction(action)
  let g:Plum_Actions = get(g:, 'Plum_Actions', plum#defaults#DefaultActions())
  call add(g:Plum_Actions, a:action)
endfunction

function! Plum_InsertAction(index, action)
  let g:Plum_Actions = get(g:, 'Plum_Actions', plum#defaults#DefaultActions())
  call insert (g:Plum_Actions, a:action, a:index)
endfunction

function! Plum_ReplaceAction(index, action)
  let g:Plum_Actions = get(g:, 'Plum_Actions', plum#defaults#DefaultActions())
  let g:Plum_Actions[a:index] = a:action
endfunction

function! Plum_ReplaceNamedAction(name, action)
  let g:Plum_Actions = get(g:, 'Plum_Actions', plum#defaults#DefaultActions())
  for i in range(len(g:Plum_Actions))
    if g:Plum_Actions[i]['name'] ==# a:name
      let g:Plum_Actions[i] = a:action
    endif
  endfor
endfunction
