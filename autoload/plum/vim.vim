function! plum#vim#Execute()
  return [ { c, _ -> [c[2:], c[0:1] ==# ': ' }
        \, { c, _ -> execute c }
        \]
endfunction
