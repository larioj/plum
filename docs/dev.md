# Development

## Files
    .
    ├── README.md
    ├── autoload
    │   ├── plum
    │   │   ├── extensions.vim
    │   │   ├── fso.vim
    │   │   ├── term.vim
    │   │   ├── util.vim
    │   │   └── vim.vim
    │   └── plum.vim
    └── docs
        ├── dev.md
        └── notes.yaml

## Context Object

### context.mode
Always set. Must be one of 'i', 'n' or visualmode(). see `: help visualmode()`.

### context.content
Always set. Either the line under cursor or visual selection.

### context.selection
Set when mode is 'v'. Contains visual selection.

### context.line
Set when mode in ['i', 'n']. Contain line under cursor.

### context.path
Set when mode in ['i', 'n']. Contain path under cursor.

## Commands
    $ tree .
    $ git rm -f autoload/plum/system.vim
    $ git grep plum#core#Plum
    $ git rm -f plugin/plum.vim
    $ git checkout -b simplify_core
    $ git diff
    $ git status
    $ git add .
    $ git commit -m "update docs"
    $ git push
    $ git push --set-upstream origin simplify_core
    $ git grep plum#matchers
