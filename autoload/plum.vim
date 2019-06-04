function! plum#Plum(mode, shift, ...)
  let actions = plum#core#GlobalActions()
  let context = plum#core#GlobalContext(a:mode, a:shift, a:000)
  let settings = plum#core#GlobalSettings()
  let buffer_actions = plum#core#BufferActions()
  return plum#core#Execute(actions, context, settings, buffer_actions)
endfunction

function! plum#Execute(actions, context, ...)
  let actions = a:actions
  let context = a:context
  let settings = get(a:, 2, { 'debug' : 0 })
  let buffer_actions = get(a:, 3, [])
  for action in buffer_actions + actions
    if settings.debug | echom action | endif
    let action_matches = 0
    try
      let action_matches = action.matches(context)
    catch /^Vim\%((\a\+)\)\=:E/
      let action_matches = 0
      echom 'caught exeption in ' . action.name . '.matches'
    endtry
    if action_matches
      if settings.debug | echom action.name . ' matches context' | endif
      let err = 0
      try
        let err = action.apply(context)
      catch /^Vim\%((\a\+)\)\=:E/
        let err = 'caught exeption in ' . action.name . '.apply'
      endtry
      if err !=# 0
        echom action.name . ' FAILURE: ' . msg
        echom 'continuing to next action'
      else
        return
      endif
    endif
  endfor
endfunction

function! plum#GlobalContext(mode, shift, ...)
  let context = get(a:, 2, {})
  let context.mode = a:mode
  let context.shift = a:shift
  if context.mode ==# 'v'
    let context.selection = plum#extensions#GetVisualSelection()
    let context.content = context.selection
  endif
  if context.mode ==# 'n' || context.mode ==# 'i'
    let context.line = plum#extensions#GetLine()
    let context.path  = plum#extensions#GetPath()
    let context.content = context.line
  endif
endfunction

function! plum#GlobalSettings()
  let g:plum_debug = get(g:, 'plum_debug', 0)
  return { 'debug' : g:plum_debug }
endfunction

function! plum#GlobalActions()
  let g:plum_actions = get(g:, 'plum_actions', [])
  return g:plum_actions
endfunction

function! plum#BufferActions()
  let b:plum_actions = get(b:, 'plum_actions', [])
  return b:plum_actions
endfunction

function! plum#CreateAction(name, matches, apply)
    return {
        \ 'name': a:name,
        \ 'matches' : plum#util#Fun(a:matcher),
        \ 'apply' : plum#util#Fun(a:action),
        \ }
endfunction

function! plum#SetMouseBindings()
  nnoremap <RightMouse> <LeftMouse>:call plum#Plum('n', 0)<cr>
  vnoremap <RightMouse> <LeftMouse>:<c-u>call plum#Plum(visualmode(), 0)<cr>
  inoremap <RightMouse> <LeftMouse><esc>:call plum#Plum('i', 0)<cr>
  nnoremap <S-RightMouse> <LeftMouse>:call plum#Plum('n', 1)<cr>
  vnoremap <S-RightMouse> <LeftMouse>:<c-u>call plum#Plum(visualmode(), 1)<cr>
  inoremap <S-RightMouse> <LeftMouse><esc>:call plum#Plum('i', 1)<cr>
endfunction
