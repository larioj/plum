function! plum#core#Plum(...)
  let l:options = call('plum#core#ResolveOptions', a:000)
  if l:options['mode'] ==# 'v'
    let l:options['vselection'] = plum#extensions#GetVisualSelection()
  endif
  if l:options['mode'] ==# 'n' || l:options['mode'] ==# 'i'
    let l:options['line'] = plum#extensions#GetLine()
    let l:options['cfile'] = plum#extensions#GetPath()
  endif

  let g:Plum_Actions = get(g:, 'Plum_Actions', plum#defaults#DefaultActions())
  let b:Plum_Actions = get(b:, 'Plum_Actions', [])
  for l:action in b:Plum_Actions + g:Plum_Actions
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
