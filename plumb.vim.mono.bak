" Win Functions ===============
function! Open(path)
  if a:path ==# ""
    return ""
  endif
  execute "edit " . a:path
endfunction

function! WinOpen(path)
  if a:path ==# ""
    return ""
  endif
  execute "below split " . a:path
endfunction

function! Scratch(dir)
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  let b:plumb_basedir = a:dir
  execute 'setlocal statusline=' . fnameescape(a:dir)
endfunction

" String Functions =======================
function! StrAt(str, idx)
  if a:idx >=# len(a:str)
    return ""
  endif
  return strpart(a:str, a:idx, 1)
endfunction

function! Trim(str)
  let l:s = 0
  while l:s <# len(a:str)
    let l:char = StrAt(a:str, l:s)
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
    let l:char = StrAt(a:str, l:e)
    if l:char ==# " " || l:char == "\t"
      let l:e = l:e - 1
    else
      break
    endif
  endwhile

  return a:str[l:s : l:e]

endfunction


" Path Functions  ========================
function! GetPathSep()
  return "/"
endfunction

function! IsAbsPath(path)
  if a:path ==# ""
    echom "IsAbsPath: Got empty path"
    return 0
  endif
  let l:simplepath = simplify(a:path)
  let l:pathHead = strpart(l:simplepath, 0, 1)
  return l:pathHead ==# GetPathSep()
endfunction

function! HasTrailSep(path)
  if a:path ==# ""
    echom "HasTrailSep: Got empty path"
    return 0
  endif
  let l:pathTail = strpart(a:path, len(a:path) -1, 1)
  return l:pathTail ==# GetPathSep()
endfunction

function! PathJoin(base, rel)
  if a:base ==# ""
    return a:rel
  endif
  if a:rel ==# ""
    return a:base
  endif
  if HasTrailSep(a:base)
    return a:base . a:rel
  else
    return a:base . "/" . a:rel
  endif
endfunction

function! FileExists(path)
  return filereadable(a:path)
endfunction

function! DirExists(path)
  return isdirectory(a:path)
endfunction

function! ResolveFso(path, FsoExists)
  let l:simplepath = simplify(expand(a:path))

  " Absolute file
  let l:fullpath = l:simplepath
  if IsAbsPath(l:fullpath)
    if a:FsoExists(l:fullpath)
      return simplify(l:fullpath)
    else
      echom "Unable to find absolute path: " . a:path
      return "" " Failure
    endif
  endif

  " Relative to plumb base
  if exists('b:plumb_basedir')
    let l:plumbpath = PathJoin(b:plumb_basedir, l:simplepath)
    if a:FsoExists(l:plumbpath)
      return simplify(l:plumbpath)
    endif
  endif

  " File relative to base
  let l:base = getcwd()
  let l:basepath = PathJoin(l:base, l:simplepath)
  if a:FsoExists(l:basepath)
    return simplify(l:basepath)
  endif

  " File relative to buffer
  let l:buffer = expand('%:p:h')
  let l:bufferpath = PathJoin(l:buffer, l:simplepath)
  if a:FsoExists(l:bufferpath)
    return simplify(l:bufferpath)
  endif

  echom "Unable to find relative path: " . a:path
  return "" " Failure
endfunction

function! ResolveFile(path)
  return ResolveFso(a:path, function("FileExists"))
endfunction

function! ResolveDir(path)
  return ResolveFso(a:path, function("DirExists"))
endfunction

" Get Components =================
function! GetSelection()
  let l:register = @@
  normal! `<v`>y
  let l:selected = @@
  let @@ = l:register
  return l:selected
endfunction

function! GetPath()
  return expand("<cfile>")
endfunction

function! GetLine()
  return getline(".")
endfunction

" Execute ======================
function! Execute(command)
  execute '$read ! '. a:command
endfunction

function! ViExec(command)
  execute a:command
endfunction

function! Exec(command, dir)
  echom "Exec('" . a:command . "')"
  enew
  call Scratch(a:dir)
  call Execute(a:command)
endfunction

function! WinExec(command, dir)
  echom "Exec('" . a:command . "')"
  below new
  call Scratch(a:dir)
  call Execute(a:command)
endfunction

" Plumb =========================
function! Plumb(GetContent)
  let l:raw = a:GetContent()

  let l:path = ResolveFile(l:raw)
  if l:path !=# ""
    call Open(l:path)
    return 1
  endif

  let l:dir = ResolveDir(l:raw)
  if l:dir !=# ""
    call Exec('find ' . l:raw . ' -maxdepth 1 | sort', l:dir)
    return 1
  endif
endfunction

function! WinPlumb(GetContent)
  let l:raw = a:GetContent()

  let l:path = ResolveFile(l:raw)
  if l:path !=# ""
    call WinOpen(l:path)
    return 1
  endif

  let l:dir = ResolveDir(l:raw)
  if l:dir !=# ""
    call WinExec('find ' . l:raw . ' -maxdepth 1 | sort', l:dir)
    return 1
  endif
endfunction

function! PlumbNormal()
  return Plumb(function("GetPath"))
endfunction

function! WinPlumbNormal()
  if WinPlumb(function("GetPath"))
    return 1
  endif

  let l:line = Trim(GetLine())
  if len(l:line ># 2)
    let l:pre = strpart(l:line, 0, 2)
    let l:command = strpart(l:line, 2, len(l:line))
    if l:pre ==# "$ "
      call Term(l:command)
      return 1
    endif
    if l:pre == ": "
      call ViExec(l:command)
      return 1
    endif
  endif
endfunction

function! PlumbVisual()
  return Plumb(function("GetSelection"))
endfunction

function! WinPlumbVisual()
  return WinPlumb(function("GetSelection"))
endfunction

" Exec Types ========================
function! ExecNormal()
  let l:line = GetLine()
  let l:dir = expand('%:p:h')
  call WinExec(l:line, l:dir)
endfunction

function! ViExecNormal()
  let l:line = GetLine()
  call ViExec(l:line)
endfunction

function! Term(command)
  execute "terminal " . a:command
endfunction

function! TermNormal()
  call Term(GetLine())
endfunction

" Scratch ===========================
function! OpenScratch()
  let l:dir = expand('%:p:h')
  below new
  call Scratch(l:dir)
endfunction

" Key Mappings =======================
nnoremap <leader>o :silent call WinPlumbNormal()<cr>
nmap <RightMouse> <LeftMouse><leader>o
imap <RightMouse> <LeftMouse><esc><leader>o

nnoremap <leader>O :call PlumbNormal()<cr>
nmap <S-RightMouse> <LeftMouse><leader>O
imap <S-RightMouse> <LeftMouse><esc><leader>O

vnoremap <leader>o :<c-u>call WinPlumbVisual()<cr>
vmap <RightMouse> <leader>o

vnoremap <leader>O :<c-u>call PlumbVisual()<cr>
vmap <S-RightMouse> <leader>O

nnoremap <leader>es :call ExecNormal()<cr>
nmap <C-MiddleMouse> <LeftMouse><leader>es

nnoremap <leader>ev :call ViExecNormal()<cr>
nmap <M-MiddleMouse> <LeftMouse><leader>ev

nnoremap <leader>et :call TermNormal()<cr>
nmap <M-LeftMouse> <LeftMouse><leader>et
nmap <MiddleMouse> <LeftMouse><leader>et

" Temporary =====================
nnoremap <leader>s :source % <cr>

" Notes
