# Development
    : vsplit
    : split docs/core.md

## Files
    .
    ├── README.md
    ├── autoload
    │   ├── plum
    │   │   ├── actions.vim
    │   │   ├── defaults.vim
    │   │   ├── extensions.vim
    │   │   ├── fso.vim
    │   │   ├── matchers.vim
    │   │   ├── system.vim
    │   │   ├── term.vim
    │   │   ├── util.vim
    │   │   └── vim.vim
    │   └── plum.vim
    └── docs
        ├── dev.md
        └── notes.yaml

## Commands
    $ git grep plum#core#Plum
    $ git rm -f plugin/plum.vim
    $ git checkout -b simplify_core
    $ git status
    $ git add .
    $ git commit
    $ git push
