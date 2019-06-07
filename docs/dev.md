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

## Set Up Git Access Token
    $ git config credential.helper store
