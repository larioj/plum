# Development

* ~/.vimrc

## Core

* autoload/plum.vim
* autoload/plum/util.vim

## Core Commands

* autoload/plum/vim.vim
* autoload/plum/fso.vim
* autoload/plum/term.vim

## Window Manager Agnostic Commands

* autoload/plum/term2.vim
* autoload/plum/fso2.vim

## Extra Commands

* autoload/plum/tree.vim
* autoload/plum/markdown.vim

## Window Managers

* autoload/plum/layout.vim
* autoload/winman.vim

## Examples

    $ git grep plum#win
    : echo "hello\n" . "foo"
    $ echo "foo\n" bar
    $ git grep plum#term#NextWindow
    $ echo hello && sleep 2
    $ sleep 8
    $ tree .
    autoload/plum/util.vim:27,29
    $ echo foo \
          bar
    $ cat <<EOF
    euateha
    unahoneth
    nuathoet
    EOF
    $ bash --help
    $ bash <<EOF
    echo hello
    EOF
    $ git diff
    $ echo

### Markdown Blocks
```sh
echo hello
```
