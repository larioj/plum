# Development

* autoload/plum.vim
* autoload/plum/vim.vim
* autoload/plum/fso.vim
* autoload/plum/term.vim

## Files
    .
    ├── README.md
    ├── autoload
    │   ├── plum
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

## Dev
* docs/lambdas.md
: echo "hll"
$ echo hello 
$ echo


