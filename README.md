# Plum
Right click on text to execute an action. The action that executes is dependent
on the text clicked.

## History
This plugin was inspired by [Acme](https://9fans.github.io/plan9port/man/man1/acme.html)
editor's middle click and right click functionality.

## Demo
<a href="https://cl.ly/0a0C1S263C3Q" target="_blank">
  <img src="https://drh2acu5z204m.cloudfront.net/items/0A1E1l2q412U1c1C062n/Screen%20Recording%202018-08-19%20at%2008.36%20PM.gif"
       style="display: block;height: auto;width: 100%;"/>
</a>

## Installation Instructions
Install using Vundle or Pathogen

## Recomended Configuration In .vimrc
```viml
set mouse=a
call plum#SetMouseBindings()
let g:plum_actions = [
      \ plum#term#SmartTerminal(),
      \ plum#vim#Execute(),
      \ plum#fso#OpenFso(),
      \ ]
```

Note that vim8 or neovim is required for the terminal actions.

## Extension Plugins
* [plum-tree](https://github.com/larioj/plum-tree)
