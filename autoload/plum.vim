function! plum#Plum(...)
  let trigger = get(a:, 1, '')
  let actions = get(g:, 'plum_actions', [])
  let b_actions = get(b:, 'plum_actions', [])
  let content = s:modify(trim(plum#util#visualorline()))
  for [extract, act] in b_actions + actions
    let [text, is_match] = extract(content, trigger)
    if is_match
      act(text, trigger)
      break
    endif
  endfor
endfunction

function! s:modify(text)
  let mods = get(g:, 'plum_mods', [])
  let b_mods = get(b:, 'plum_mods', [])
  let r = a:text
  for m in b_mods + mods
    r = m(copy(r))
  endfor
  return r
endfunction

function! plum#SetMouseBindings()
  nnoremap <RightMouse> <LeftMouse>:call plum#Plum('RightMouse')<cr>
  vnoremap <RightMouse> <LeftMouse>:<c-u>call plum#Plum('RightMouse')<cr>
  inoremap <RightMouse> <LeftMouse><esc>:call plum#Plum('RightMouse')<cr>
  nnoremap <S-RightMouse> <LeftMouse>:call plum#Plum('S-RightMouse')<cr>
  vnoremap <S-RightMouse> <LeftMouse>:<c-u>call plum#Plum('S-RightMouse')<cr>
  inoremap <S-RightMouse> <LeftMouse><esc>:call plum#Plum('S-RightMouse')<cr>
endfunction
