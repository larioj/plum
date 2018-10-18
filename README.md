# Plum
This pluging brings some of the plan9port plumber functionality to vim.
Inspired by [Acme](https://9fans.github.io/plan9port/man/man1/acme.html)
editor's middle click and left click functionality.

## Development Status
This is a very new plugin. Still testing it out. It may have lots of bugs, and the API may change.

<a href="https://cl.ly/0a0C1S263C3Q" target="_blank"><img src="https://drh2acu5z204m.cloudfront.net/items/0A1E1l2q412U1c1C062n/Screen%20Recording%202018-08-19%20at%2008.36%20PM.gif" style="display: block;height: auto;width: 100%;"/></a>

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
set mouse=a
runtime plugin/plum.vim
call Plum_SetLeftMouseBindings()
```

## A Smarter Terminal Action
If you would like empty terminal windows to automatically close, and the
commands to reuse any old open windows, you can change the default terminal
action. This is what I use in my setup, but given that the terminal feature
is experimental, I've been running into some issues. On some versions of vim
this may segfault. Beware :|

```viml
" Enable Mouse Bindings
set mouse=a
runtime plugin/plum.vim
call Plum_SetLeftMouseBindings()

" Replace default terminal action with smart terminal action
" this may cause segfaults on some vims :|
call Plum_ReplaceNamedAction(
      \ 'DefaultTerminalAction',
      \ plum#defaults#SmartTerminalAction())
```

## TODO
* [x] Make terminal expand variables
* [ ] Make terminal action work on vim w/o +terminal
* [ ] Make filepaths accept line numbers
* [ ] Left click on word goes to search i.e. `nomal! *`

## Contributing
Pull request welcome :)
