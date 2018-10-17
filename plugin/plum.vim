let g:Plum_DebugEnabled = get(g:, 'Plum_DebugEnabled', 0)
let b:Plum_DebugEnabled = get(b:, 'Plum_DebugEnabled', 0)

let g:Plum_Actions = get(g:, 'Plum_Actions', plum#defaults#DefaultActions())
let b:Plum_Actions = get(b:, 'Plum_Actions', [])

function! Plum_SetLeftMouseBindings()
  call plum#defaults#SetLeftMouseBindings()
endfunction

function! Plum_CreateAction(name, matcher, action)
  let l:matcher_fun = a:matcher
  if type(a:matcher) ==# type("")
    let l:matcher_fun = function(a:matcher)
  endif
  let l:action_fun = a:action
  if type(a:action) ==# type("")
    let l:action_fun = function(a:action)
  endif
  return {
        \ 'name': a:name,
        \ 'matcher' : l:matcher_fun,
        \ 'action' : l:action_fun,
        \ }
endfunction

function! Plum_InsertAction(index, action)
  let g:Plum_Actions = get(g:, 'Plum_Actions', plum#defaults#DefaultActions())
  call insert (g:Plum_Actions, a:action, a:index)
endfunction

function! Plum_ReplaceActionByName(old_name, action)
  let g:Plum_Actions = get(g:, 'Plum_Actions', plum#defaults#DefaultActions())
  "TODO(larioj): Finish this
endfunction

function! Plum_ReplaceAction(index, action)
  let g:Plum_Actions = get(g:, 'Plum_Actions', plum#defaults#DefaultActions())
  "TODO(larioj): Finish this
endfunction
