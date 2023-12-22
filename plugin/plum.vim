" Configuration
let g:plum_pits = get(g:, 'plum_pits', [])
let g:plum_enable_mouse_bindings = get(g:, 'plum_enable_mouse_bindings', 1)
let g:default_term_opts =  get(g:, 'default_term_opts', {})


function! s:job_handler(job_id, data, event) abort
   if a:event ==# 'stdout'
       call nvim_buf_set_lines(bufnr('%'), -2, -1, v:true, a:data)
   endif
endfunction

let g:default_job_opts = get(g:, 'default_job_opts', {
       \ 'on_stdout': function('s:job_handler'),
       \ 'stdout_buffered': v:true,
       \ })

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

function! ExtractTermAdapter(marker)
 let [result, is_match] = plum#term#Extract(a:marker)
 if is_match
   return result
  endif
  return v:null
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

function! s:WithCondH(Cond, Extract)
  let result = a:Extract()
  if result != v:null && a:Cond(result)
    return result
  endif
  return v:null
endfunction
let g:WithCond = { c, e -> { -> s:WithCondH(c, e) } }
let g:WithFiletype = { ft, e -> g:WithCond({ _ -> &filetype is# ft }, e) }
let g:WithSubstr = { sub, e -> g:WithCond({ c -> stridx(c, sub) != -1 }, e) }
let g:WithRegex = { rx, e -> g:WithCond({ c -> c =~# rx }, e) }

" Extracts
let g:Any = { -> 1 }

let g:ExtractLine = AltVisual({ -> getline('.') })
let g:ExtractWord = AltVisual({ -> expand('<cword>') })
let g:ExtractFile = { -> expand('%:p') }
let g:ExtractCFile = AltVisual({ -> expand(expand('<cfile>')) })

let g:ExtractDir = WithCond({c -> isdirectory(c)}, g:ExtractCFile)
let g:ExtractTerm = { -> ExtractTermAdapter('$ ') }
let g:ExtractVim = WithTrimPrefix(': ', g:ExtractLine)
let g:ExtractRepoWord = WithCond({ _ -> trim(system('git rev-parse --is-inside-work-tree 2>/dev/null')) == 'true' }, g:ExtractWord)
let g:ExtractUrl = WithRegex('\v^https?://.+$', g:ExtractCFile)


function! ExtractCFileNH()
  let sav = &isfname
  set isfname+=:
  let p = expand('<cfile>')
  let &isfname = sav
  return expand(p)
endfunction
let g:ExtractCFileN = AltVisual({ -> ExtractCFileNH() })

" Github Repo Markdown Handling
function! IsMdCFile()
  if &filetype is# 'markdown'
    let sav = &isfname
    set isfname+=(
    let p = expand('<cfile>')
    let &isfname = sav
    return p[0] == '('
  endif
  return 0
endfunction

function! FileBase()
  return expand('%:p:h')
endfunction

function! RepoBase(dir)
  let dir = a:dir
  while ! isdirectory(dir)
    let dir = fnamemodify(dir, ':h')
  endwhile
  let p = substitute(system('cd ' . dir . ' && git rev-parse --show-toplevel'), '\n$', '', '')
  if v:shell_error == 0
    return p
  endif
  return v:null
endfunction

function! ExtractRepoMdCFileNH()
  let p = g:ExtractCFileN()
  if ! IsMdCFile()
    return v:null
  endif
  if p[0] == '/'
    let repo_base = RepoBase(FileBase())
    if repo_base != v:null
      return repo_base . p
    endif
    return v:null
  endif
  return FileBase() . '/' . p
endfunction
let g:ExtractRepoMdCFileN = { -> ExtractRepoMdCFileNH() }

" Actions
function! TermOpenH(c)
  new
  call termopen(a:c, g:default_term_opts)
endfunction

function! JobStartH(c)
  new
  call jobstart(a:c, g:default_job_opts)
endfunction

let g:Execute = { c -> execute(c, '') }
let g:Cd = { c -> execute('lcd ' . c) }
let g:TermOpen = { c -> TermOpenH(c) }
let g:JobStart = { c -> JobStartH(c) }
let g:GitGrep = { c -> g:JobStart('git grep ' . shellescape(c)) }
let g:MacOpen = { c -> jobstart('open ' . shellescape(trim(c))) }

function! FsoOpenH(c)
  let parts = split(a:c, ':')
  call execute('split ' . parts[0])
  if len(parts) > 1
    call execute(parts[1])
  endif
endfunction
let g:FsoOpen = { c -> FsoOpenH(c) }

" Bindings
if g:plum_enable_mouse_bindings
  nnoremap o :call Plum('n', 0)<cr>
  vnoremap o :<c-u>call Plum('v', 0)<cr>
  nnoremap <RightMouse> :call Plum('n', 1)<cr>
  vnoremap <RightMouse> :<c-u>call Plum('v', 1)<cr>
  inoremap <RightMouse> <esc>:call Plum('i', 1)<cr>
endif
