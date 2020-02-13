function! plum#Plum(...)
  let trigger = get(a:, 1, '')
  let actions = get(g:, 'plum_actions', [])
  let b_actions = get(b:, 'plum_actions', [])
  let content = trim(plum#util#visualorline())
  for [Extract, Act] in b_actions + actions
    let [text, is_match] = Extract(content, trigger)
    if is_match
      call Act(text, trigger)
      break
    endif
  endfor
endfunction

function! plum#SetMouseBindings()
  nnoremap <RightMouse> <LeftMouse>:call plum#Plum('RightMouse')<cr>
  vnoremap <RightMouse> <LeftMouse>:<c-u>call plum#Plum('RightMouse')<cr>
  inoremap <RightMouse> <LeftMouse><esc>:call plum#Plum('RightMouse')<cr>
  nnoremap <S-RightMouse> <LeftMouse>:call plum#Plum('S-RightMouse')<cr>
  vnoremap <S-RightMouse> <LeftMouse>:<c-u>call plum#Plum('S-RightMouse')<cr>
  inoremap <S-RightMouse> <LeftMouse><esc>:call plum#Plum('S-RightMouse')<cr>
endfunction
