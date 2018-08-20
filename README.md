# Plumber
This pluging brings some of the plan9port plumber functionality to vim.
Inspired by [Acme](https://9fans.github.io/plan9port/man/man1/acme.html)
editor's middle click and left click functionality.

## Default Functionalty
* Left Click on File Path -> Open File in split
* Left Click on Dir Path -> Open scratch buffer with find listing
* Left Click on ': some-text' -> execute command as viml (note: space after : is not optional)
* Left Click on '$ some-text' -> execute command in terminal (note: space after $ is not optional)
* Shift Left Click same as Shift Left but opens in same window

## Installation Instructions
Install using Vundle or Pathogen

## Enabling Mouse Bidings
Add the following to your .vimrc:

```viml
" Enable Mouse Bindings
runtime pluging/plumb.vim
call Plumb_SetLeftMouseBindings()
```
## TODO
* [ ] Left click on word goes to search i.e. `nomal! *`
