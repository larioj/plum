# Experimental Branch

## Configuration
```viml
let g:plum_actions = [
      \ [prefix('$ ', [visual, terminal_block]), winman_enew(open_term)], 
      \ [prefix('% ', [visual, terminal_block]), winman_enew(start_job)], 
      \ [prefix(': ', line), plum_execute_vim], 
      \ [fso, winman_new(plum_open_fso)]
      \ [dir, change_dir)]
      \ ]
```

## Core
- plugin/plum.vim
- autoload/plum.vim
- autoload/plum/util.vim
- autoload/plum/term.vim

$ <terminal cmd> -> open terminal
% <terminal cmd> -> open terminal

$ git grep 'term'
% git grep 'term'

: echo 'hello'
: cd repos/plum
$ git status


## Configuration
- ~/.config/nvim/init.vim
