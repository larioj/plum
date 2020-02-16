function! plum#vim#Execute()
  return [ { c, _ -> [trim(c)[2:], trim(c)[0:1] ==# ': '] }
        \, { c, _ -> execute(c, '') } ]
endfunction
