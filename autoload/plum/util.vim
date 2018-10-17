function! plum#util#DictUnion(base, diff)
  let l:result = deepcopy(a:base)
  for l:k in keys(a:diff)
    let l:result[l:k] = a:diff[l:k]
  endfor
  return l:result
endfunction

function! plum#util#StrAt(str, idx)
  if a:idx >=# len(a:str)
    return ""
  endif
  return strpart(a:str, a:idx, 1)
endfunction

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
    return function(str_or_fun)
  endif
  return str_or_fun
endfunction

" Returns index or len(list) if not found
function! plum#util#FindIndexWhere(list, pred)
  let l:pred_fun = plum#util#Fun(a:pred)
  let l:i = 0
  while l:i <# len(a:list) - 1
    let l:element = get(a:list, l:i)
    if l:pred_fun(l:element)
      return l:i
    endif
    let l:i = l:i + 1
  endwhile
  return l:i
endfunction
