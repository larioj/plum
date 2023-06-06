" Configuration
let g:plum_pits = get(g:, 'plum_pits', [])
let g:plum_enable_mouse_bindings = get(g:, 'plum_enable_mouse_bindings', 1)
let g:default_term_opts =  get(g:, 'default_term_opts', {})
let g:default_job_opts = get(g:, 'default_job_opts', {})

" Core
function! Plum(...)
  let g:plum_mode = get(a:, 1, 'n')
  let show_menu = get(a:, 2, 0)
  aunmenu PopUp
  let g:plum_popup_thunks = []
  let g:plum_popup_results = []
  for [name, Extract, Apply] in get(b:, 'plum_pits', []) + g:plum_pits
    let result = Extract()
    if result != v:null
      let index = string(len(g:plum_popup_thunks))
      call add(g:plum_popup_thunks, Apply)
      call add(g:plum_popup_results, result)
      "call execute(g:plum_mode . 'noremenu PopUp.' . name . ' <cmd>call g:plum_popup_thunks[' . index . '](g:plum_popup_results[' . index . '])<cr>')
      call execute('menu PopUp.' . name . ' <cmd>call g:plum_popup_thunks[' . index . '](g:plum_popup_results[' . index . '])<cr>')
    endif
  endfor
  if ! len(g:plum_popup_results)
    return
  endif
  if show_menu
    popup PopUp
  else
    call g:plum_popup_thunks[0](g:plum_popup_results[0])
  endif
endfunction

" Utilities
function! Visual()
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

" Combinator Library
function! s:FirstH(extracts)
  for Extract in a:extracts
    let result = Extract()
    if result != v:null
      return result
    endif
  endfor
  return v:null
endfunction
let g:First = { es -> { -> s:FirstH(es) } }

function! s:WithCondH(Cond, Extract)
  let result = a:Extract()
  if result != v:null && a:Cond(result)
    return result
  endif
  return v:null
endfunction
let g:WithCond = { c, e -> { -> s:WithCondH(c, e) } }

function! s:WithTrimPrefixH(prefix, Extract)
  let result = trim(a:Extract())
  if stridx(result, a:prefix) == 0
    return strpart(result, len(a:prefix))
  endif
  return v:null
endfunction
let g:WithTrimPrefix = { p, e -> { -> s:WithTrimPrefixH(p, e) } }

function! s:AltVisualH(Extract)
  if g:plum_mode == 'v'
    return Visual()
  endif
  return a:Extract()
endfunction
let g:AltVisual = { e -> { -> s:AltVisualH(e) } }

" Extracts
let g:ExtractLine = { -> getline('.') }
let g:ExtractCFile = { -> expand(expand('<cfile>')) }
let g:ExtractFile = WithCond({c -> filereadable(c)}, AltVisual(g:ExtractCFile))
let g:ExtractDir = WithCond({c -> isdirectory(c)}, AltVisual(g:ExtractCFile))
"let g:ExtractTerm = WithTrimPrefix('$ ', AltVisual(g:ExtractLine))
let g:ExtractTerm = { -> plum#term#Extract() }
let g:ExtractJob = WithTrimPrefix('% ', AltVisual(g:ExtractLine))
let g:ExtractVim = WithTrimPrefix(': ', AltVisual(g:ExtractLine))
let g:ExtractWord = { -> expand('<cword>') }
let g:ExtractRepoWord = WithCond({ _ -> trim(system('git rev-parse --is-inside-work-tree 2>/dev/null')) == 'true' }, AltVisual(g:ExtractWord))

" Actions
let g:Execute = { c -> execute(c, '') }
let g:JobStart = { c -> jobstart(['/bin/bash', '-ic', c], g:default_job_opts) }
let g:TermOpen = { c -> termopen(['/bin/bash', '-ic', c], g:default_term_opts) }
let g:FsoOpen = { c -> execute('normal gF') }
let g:Cd = { c -> execute('lcd ' . c) }
let g:GitGrep = { c -> g:TermOpen('git grep ' . shellescape(c)) }

" Winman
function! s:WinmanNewH(Fn, c)
  let count = winnr('$')
  if count == 1
    botright vnew
  else
    rightbelow new
  endif
  call a:Fn(a:c)
endfunction
let g:WinmanNew = { fn -> { c -> s:WinmanNewH(fn, c) }}

function! s:WinmanSplitH(Fn, c)
  let count = winnr('$')
  if count == 1
    botright vsplit
  else
    rightbelow split
  endif
  call a:Fn(a:c)
endfunction
let g:WinmanSplit = { fn -> { c -> s:WinmanSplitH(fn, c) }}

" Bindings
if g:plum_enable_mouse_bindings
  nnoremap <RightMouse> <LeftMouse>:call Plum('n', 1)<cr>
  vnoremap <RightMouse> <LeftMouse>:<c-u>call Plum('v', 1)<cr>
  inoremap <RightMouse> <LeftMouse><esc>:call Plum('i', 1)<cr>
endif
