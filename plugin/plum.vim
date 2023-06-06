" Configuration
let g:plum_pits = get(g:, 'plum_pits', [])
let g:plum_enable_mouse_bindings = get(g:, 'plum_enable_mouse_bindings', 1)
let g:plum_enable_key_bindings = get(g:, 'plum_enable_key_bindings', 1)
let g:default_term_opts = {}
let g:default_job_opts = {}

" Core
function! Plum()
  aunmenu PopUp
  let g:plum_popup_thunks = []
  let g:plum_popup_results = []
  for [name, Extract, Apply] in get(b:, 'plum_pits', []) + g:plum_pits
    let result = Extract()
    if result != v:null
      let index = string(len(g:plum_popup_thunks))
      call add(g:plum_popup_thunks, Apply)
      call add(g:plum_popup_results, result)
      call execute('menu PopUp.' . name . ' <cmd>call g:plum_popup_thunks[' . index . '](g:plum_popup_results[' . index . '])<cr>')
    endif
  endfor
  popup PopUp
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

" Extracts
let g:ExtractLine = { -> getline('.') }
let g:ExtractCFile = { -> expand(expand('<cfile>')) }
let g:ExtractFile = WithCond({c -> filereadable(c)}, g:ExtractCFile)
let g:ExtractDir = WithCond({c -> isdirectory(c)}, g:ExtractCFile)
let g:ExtractTerm = WithTrimPrefix('$ ', g:ExtractLine)
let g:ExtractJob = WithTrimPrefix('% ', g:ExtractLine)
let g:ExtractVim = WithTrimPrefix(': ', g:ExtractLine)
let g:ExtractWord = { -> expand('<cword>') }
let g:ExtractRepoWord = WithCond({ _ -> trim(system('git rev-parse --is-inside-work-tree 2>/dev/null')) == 'true' }, g:ExtractWord)

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
  nnoremap <RightMouse> <LeftMouse>:call Plum()<cr>
endif

