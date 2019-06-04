function! plum#vim#Execute()
  return plum#CreateAction(
        \ "plum#vim#Execute",
        \ function("s:plum#vim#IsCommand")
        \ function("s:plum#vim#ApplyExecute") )
endfunction

function! s:plum#vim#IsCommand(context)
  let context = a:context
  let content = plum#util#Trim(context.content)
  if strpart(content, 0, 2) ==# ': '
    let context.matched_text = strpart(content, 2)
    return 1
  endif
  return 0
endfunction

function! s:plum#vim#ApplyExecute(context)
  let context = a:context
  let matched_text = context.matched_text
  execute matched_text
endfunction
