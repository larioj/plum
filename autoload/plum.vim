function! plum#Plum(...)
  return call('plum#core#Plum', a:000)
endfunction

function! plum#SetBindings()
  return plum#defaults#SetRightMouseBindings()
endfunction
