function! plumb#core#Plumb(...)
  let l:options = call('plumb#core#ResolveOptions', a:000)
  if l:options['mode'] ==# 'v'
    let l:options['selection'] = plumb#extensions#GetVisualSelection()
  endif
  if l:options['mode'] ==# 'n' || l:options['mode'] ==# 'i'
    let l:options['line'] = plumb#extensions#GetLine()
    let l:options['cfile'] = plumb#extensions#GetPath()
  endif
  for l:action in b:Plumb_Actions + g:Plumb_Actions
    if l:action['matcher'](l:options) && l:action['action'](l:options)
      return
    else
      call plumb#core#Debug(l:action['name'] . ' failed')
    endif
  endfor
endfunction

function! plumb#core#ResolveOptions(...)
  let l:options = { 'mode': 'n', 'shift' : 0}
  if a:0 ># 0
    if type(a:1) ==# type({})
      let l:options = plumb#util#DictUnion(l:options, a:1)
    else
      call plumb#core#Debug('plumb::ResolveOptions::a1 unknown type: ' . type(a:1))
    endif
  endif
  if a:0 ># 1
    call plumb#core#Debug('plumb::ResolveOptions::a0 unused arguments: ' . a:0)
  endif
  return l:options
endfunction

function! plumb#core#Debug(msg)
  if g:Plumb_DebugEnabled || b:Plumb_DebugEnabled
    echom a:msg
  endif
endfunction
