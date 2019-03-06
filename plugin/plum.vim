let g:Plum_DebugEnabled = get(g:, 'Plum_DebugEnabled', 0)
let b:Plum_DebugEnabled = get(b:, 'Plum_DebugEnabled', 0)

let g:plum_actions = get(g:, 'plum_actions', plum#defaults#DefaultActions())
let b:plum_actions = get(b:, 'plum_actions', [])

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
  let g:plum_actions = get(g:, 'plum_actions', plum#defaults#DefaultActions())
  call add(g:plum_actions, a:action)
endfunction

function! Plum_InsertAction(index, action)
  let g:plum_actions = get(g:, 'plum_actions', plum#defaults#DefaultActions())
  call insert (g:plum_actions, a:action, a:index)
endfunction

function! Plum_ReplaceAction(index, action)
  let g:plum_actions = get(g:, 'plum_actions', plum#defaults#DefaultActions())
  let g:plum_actions[a:index] = a:action
endfunction

function! Plum_ReplaceNamedAction(name, action)
  let g:plum_actions = get(g:, 'plum_actions', plum#defaults#DefaultActions())
  for i in range(len(g:plum_actions))
    if g:plum_actions[i]['name'] ==# a:name
      let g:plum_actions[i] = a:action
    endif
  endfor
endfunction
