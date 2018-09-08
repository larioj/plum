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
runtime plugin/plum.vim
call Plum_SetLeftMouseBindings()
```
## TODO
* [x] Make terinal expand variables
* [ ] Make non-existent paths, with existing dir open a buffer
* [ ] Left click on word goes to search i.e. `nomal! *`
* [ ] Make filepaths accept line numbers

## Contributing
Pull request welcome :)
