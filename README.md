# vim-fennel-syntax

Vim syntax highlighting for [Fennel][1].
This repo is a personal fork from the original [fennel.vim][2].

## Installation

Follow usual vim plugin installation procedure.

## Options

For all options below, if both global and buffer local ones are found, the
buffer local one takes precedence.  In the example codes, only global options
`g:...` are shown but `b:...` also works.

### fennel_use_lume

This option enables highlighting for functions provided by [Lume][3].

```vim
let g:fennel_use_lume = 1  " default: 1
```

## License

[MIT](LICENSE)

[1]: https://fennel-lang.org/
[2]: https://github.com/bakpakin/fennel.vim/
[3]: https://github.com/rxi/lume/

<!-- vim: set tw=78 spell: -->
