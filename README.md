# Plum
Right click on text to execute an action. The action that executes is dependent
on the text clicked.

This plugin was inspired by [Acme](https://9fans.github.io/plan9port/man/man1/acme.html)
editor's middle click and left click functionality.

## Development Status
This is a very new plugin. Still testing it out. It may have lots of bugs,
and the interface may change.

## Demo

<a href="https://cl.ly/0a0C1S263C3Q" target="_blank"><img src="https://drh2acu5z204m.cloudfront.net/items/0A1E1l2q412U1c1C062n/Screen%20Recording%202018-08-19%20at%2008.36%20PM.gif" style="display: block;height: auto;width: 100%;"/></a>

## plum#fso#Directory()
Right click on an existing directory to open a window that lists the contents of
that directory.

## plum#fso#File()
Right click on file path to open the file.

## plum#term#Terminal()
Right click on a line starting with `$` to execute the command as `bash` in a new terminal window.
**Note** that there needs to be space between the `$` and the command i.e. `$ echo
hello` **NOT** `$echo hello`.
**Note** requires a vim that `has('terminal') != 0`.

## plum#term#SmartTerminal()
Same as above but automatically closes empty windows and reuses windows for the
same command. **BEWARE** this may cause **segfaults** on some vim versions.
**Note** requires a vim that `has('terminal') != 0`.

## plum#vim#Execute()
Right click on a line starting with `:` to execute the command as `viml`.
**Note** that there needs to be space between the `:` and the command i.e. `:
echo 'foo'` **NOT** `:echo 'foo'`.

## Installation Instructions
Install using Vundle or Pathogen

## Enabling Mouse Bindings
Add the following to your .vimrc:
```viml
set mouse=a
call plum#SetBindings()
let g:Plum_Actions = [
      \ plum#fso#Directory(),
      \ plum#fso#File(),
      \ plum#term#Terminal(),
      \ plum#vim#Execute()
      \ ]
```

Or if you would like to use the smart terminal action:
```viml
" Enable Mouse Bindings
set mouse=a
call plum#SetBindings()
let g:Plum_Actions = [
      \ plum#fso#Directory(),
      \ plum#fso#File(),
      \ plum#term#SmartTerminal(),
      \ plum#vim#Execute()
      \ ]
```

## Extension Plugins
* [plum-tree](https://github.com/larioj/plum-tree)
* [plum-purescript](https://github.com/larioj/plum-purescript)

## Developing Your Own Actions
**TODO** Open an issue if you would like some advice, and the I'll fill thin in.
[plum-tree](https://github.com/larioj/plum-tree) is an intermediate example of how to do this.

## TODO
* [ ] Make terminal action work on vim w/o +terminal
* [ ] Make file paths accept line numbers
* [ ] Catch all right click on word goes to next occurrence

## Contributing
Use it! File bugs, and create pull requests :)

## Contributing Actions
Create a plugin a then create a pull request to link it from this readme.
[plum-purescript](https://github.com/larioj/plum-purescript) is a very small example.
