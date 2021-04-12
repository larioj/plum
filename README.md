# Plum
*Vim 8.2 required*. Execute action based upon the content under cursor.

## Demo

    # lines starting with ': ' are treated as vim expressions
    : echo 'hello'

    # lines starting with '$ ' are treated as terminal expressions
    $ echo hello

    # you can execute muliline expressions
    $ echo \
        hello

    # you can execute heredocs
    $ cat <<EOF
      hey there
    EOF

    $HOME/.vimrc

## Installation Instructions
Install using Vundle or Pathogen

Note that vim8 is required for the terminal actions.

## Recomended Configuration In .vimrc
```viml
set mouse=a
call plum#SetMouseBindings()
nnoremap , :call plum#Plum()<cr>
let g:plum_actions = [
      \ plum#term#Terminal(),
      \ plum#vim#Execute(),
      \ plum#tree#OpenFso(),
      \ plum#fso#OpenFso(),
      \ ]
```

## Don't want to use the mouse?
```viml
nnoremap , :call plum#Plum()<cr>
let g:plum_actions = [
      \ plum#term#Terminal(),
      \ plum#vim#Execute(),
      \ plum#tree#OpenFso(),
      \ plum#fso#OpenFso(),
      \ ]
```
