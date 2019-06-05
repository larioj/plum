function! plum#util#Trim(str)
  let l:s = 0
  while l:s <# len(a:str)
    let l:char = plum#util#StrAt(a:str, l:s)
    if l:char ==# " " || l:char == "\t"
      let l:s = l:s + 1
    else
      break
    endif
  endwhile

  if l:s ==# len(a:str)
    return ""
  endif

  let l:e = len(a:str) - 1
  while l:e >=# 0
    let l:char = plum#util#StrAt(a:str, l:e)
    if l:char ==# " " || l:char == "\t"
      let l:e = l:e - 1
    else
      break
    endif
  endwhile
  return a:str[l:s : l:e]
endfunction

function! plum#util#Fun(str_or_fun)
  if type(a:str_or_fun) ==# type("")
    return function(a:str_or_fun)
  endif
  return a:str_or_fun
endfunction
