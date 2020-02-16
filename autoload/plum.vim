function! plum#Plum(...)
  let trigger = {'mode': get(a:, 1, 'n'), 'key': s:support_v1(get(a:, 2, ''))}
  let b:plum_trigger_mode = trigger.mode 
  let actions = get(g:, 'plum_actions', [])
  let b_actions = get(b:, 'plum_actions', [])
  let content = plum#util#visualorline()
  for [Extract, Act] in b_actions + actions
    let [result, is_match] = Extract(content, trigger)
    if is_match
      call Act(result, trigger)
      break
    endif
  endfor
endfunction

function! s:support_v1(key)
  if type(a:key) ==# type(0) && a:key !=# 0
    return 'Shift'
  endif
  return ''
endfunction

function! plum#SetMouseBindings()
  nnoremap <RightMouse> <LeftMouse>:call plum#Plum('n', 'RightMouse')<cr>
  vnoremap <RightMouse> <LeftMouse>:<c-u>call plum#Plum('v', 'RightMouse')<cr>
  inoremap <RightMouse> <LeftMouse><esc>:call plum#Plum('i', 'RightMouse')<cr>
  nnoremap <S-RightMouse> <LeftMouse>:call plum#Plum('n', 'S-RightMouse')<cr>
  vnoremap <S-RightMouse> <LeftMouse>:<c-u>call plum#Plum('v', 'S-RightMouse')<cr>
  inoremap <S-RightMouse> <LeftMouse><esc>:call plum#Plum('i', 'S-RightMouse')<cr>
endfunction
