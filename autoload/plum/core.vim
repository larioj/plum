function! plum#core#Plum(...)
  " Define globals if not defined
  let g:Plum_DebugEnabled = get(g:, 'Plum_DebugEnabled', 0)
  let b:Plum_DebugEnabled = get(b:, 'Plum_DebugEnabled', 0)
  let g:plum_actions = get(g:, 'plum_actions', plum#defaults#DefaultActions())
  let b:plum_actions = get(b:, 'plum_actions', [])

  let l:options = call('plum#core#ResolveOptions', a:000)
  if l:options['mode'] ==# 'v'
    let l:options['vselection'] = plum#extensions#GetVisualSelection()
  endif
  if l:options['mode'] ==# 'n' || l:options['mode'] ==# 'i'
    let l:options['line'] = plum#extensions#GetLine()
    let l:options['cfile'] = plum#extensions#GetPath()
  endif

  for l:action in b:plum_actions + g:plum_actions
    if l:action['matcher'](l:options) && !l:action['action'](l:options)
      return
    else
      call plum#core#Debug(l:action['name'] . ' failed')
    endif
  endfor
endfunction

function! plum#core#ResolveOptions(...)
  let l:options = { 'mode': 'n', 'shift' : 0}
  if a:0 ># 0
    if type(a:1) ==# type({})
      let l:options = plum#util#DictUnion(l:options, a:1)
    else
      call plum#core#Debug('plum::ResolveOptions::a1 unknown type: ' . type(a:1))
    endif
  endif
  if a:0 ># 1
    call plum#core#Debug('plum::ResolveOptions::a0 unused arguments: ' . a:0)
  endif
  return l:options
endfunction

function! plum#core#Debug(msg)
  if g:Plum_DebugEnabled || b:Plum_DebugEnabled
    echom a:msg
  endif
endfunction
