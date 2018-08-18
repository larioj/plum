"nnoremap <RightMouse> :<c-u>call Plumb({'mode': 'n'         ,})
"vnoremap <RightMouse> :<c-u>call Plumb({'mode': visualmode(),})
"inoremap <RightMouse> :<c-u>call Plumb({'mode': 'i'         ,})
"nnoremap <S-RightMouse> :<c-u>call Plumb({'mode': 'n'         , 'shift': 1,})
"vnoremap <S-RightMouse> :<c-u>call Plumb({'mode': visualmode(), 'shift': 1,})
"inoremap <S-RightMouse> :<c-u>call Plumb({'mode': 'i'         , 'shift': 1,})

let g:Plumb_DebugEnabled = get(g:, 'Plumb_DebugEnabled', 0)
let b:Plumb_DebugEnabled = get(b:, 'Plumb_DebugEnabled', 0)

let g:Plumb_Actions = get(g:, 'Plumb_Actions', [])
let b:Plumb_Actions = get(b:, 'Plumb_Actions', [])

function! Test(...)
  let l:options = call('s:ResolveOptions', a:000)
  if l:options['mode'] ==# 'v'
    let l:options['selection?'] = s:GetVisualSelection()
  endif
  for l:action in b:Plumb_Actions + g:Plumb_Actions
    let l:isFailure = l:action(l:options)
    if l:isFailure
      call s:Debug(l:isFailure)
    else
      return
    endif
  endfor
endfunction

function! s:ResolveOptions(...)
  let l:options = { 'mode': 'n', 'shift' : 0}
  if a:0 ># 0
    if type(a:1) ==# type({})
      let l:options = s:DictUnion(l:options, a:1)
    else
      call s:Debug('plumb::ResolveOptions::a1 unknown type: ' . type(a:1))
    endif
  endif
  if a:0 ># 1
    call s:Debug('plumb::ResolveOptions::a0 unused arguments: ' . a:0)
  endif
  return l:options
endfunction

function! s:DictUnion(base, diff)
  let l:result = deepcopy(a:base)
  for l:k in keys(a:diff)
    let l:result[l:k] = a:diff[l:k]
  endfor
  return l:result
endfunction

function! s:GetVisualSelection()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, "\n")
endfunction

function! s:Debug(msg)
  if g:Plumb_DebugEnabled
    echom a:msg
  endif
endfunction
