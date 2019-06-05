function! plum#vim#Execute()
  return plum#CreateAction(
        \ "plum#vim#Execute",
        \ function("plum#vim#IsCommand")
        \ function("plum#vim#ApplyExecute") )
endfunction

function! plum#vim#IsCommand(context)
  let context = a:context
  let content = plum#util#Trim(context.content)
  if strpart(content, 0, 2) ==# ': '
    let context.match = strpart(content, 2)
    return 1
  endif
  return 0
endfunction

function! plum#vim#ApplyExecute(context)
  let context = a:context
  let match = context.match
  execute match
endfunction
