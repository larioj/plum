function! plum#mk2#Block()
  return [ { _, trigger -> plum#mk2#ExtractBlock() }
        \, { input, trigger -> plum#mk2#ExecuteBlock(input[0], input[1]) } ]
endfunction

function! plum#mk2#ReadBlock(start)
  let start = a:start
  let end = start
  let lines = [getline(end)]
  while end < line('$') && lines[-1] !=# '```'
    let end = end + 1
    call add(lines, getline(end))
  endwhile
  return lines
endfunction

function! plum#mk2#ExtractBlock()
  let start = line('.')
  let tok = '```'
  let l = getline(start)
  if l[0:2] !=# tok
    return ['', v:false]
  endif
  let cmd = l[3:]
  let body = plum#mk2#ReadBlock(start + 1)
  if body[-1] !=# tok
    return ['', v:false]
  endif
  call remove(body, -1)
  return [[cmd, body], v:true]
endfunction

function! plum#mk2#ExecuteBlock(syntax, body)
  let [syntax, body] = [trim(a:syntax), a:body]
  let interpreters = { 'bash' : '/bin/bash', 'sh': '/bin/sh' }
  call extend(interpreters, get(g:, 'plum_markdown_interpreters', {}))
  let cmd = get(interpreters, syntax, syntax)
  let heredoc = join([cmd . " <<'EOF'"] + body + ['EOF'] , "\n")
  call plum#term2#Eval(heredoc)
endfunction
