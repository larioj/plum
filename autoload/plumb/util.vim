function! plumb#util#DictUnion(base, diff)
  let l:result = deepcopy(a:base)
  for l:k in keys(a:diff)
    let l:result[l:k] = a:diff[l:k]
  endfor
  return l:result
endfunction

function! plumb#util#StrAt(str, idx)
  if a:idx >=# len(a:str)
    return ""
  endif
  return strpart(a:str, a:idx, 1)
endfunction

function! plumb#util#Trim(str)
  let l:s = 0
  while l:s <# len(a:str)
    let l:char = plumb#util#StrAt(a:str, l:s)
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
    let l:char = plumb#util#StrAt(a:str, l:e)
    if l:char ==# " " || l:char == "\t"
      let l:e = l:e - 1
    else
      break
    endif
  endwhile
  return a:str[l:s : l:e]
endfunction

