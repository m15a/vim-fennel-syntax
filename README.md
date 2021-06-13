# vim-fennel-syntax

Vim syntax highlighting for [Fennel][1].
This is a personal fork from the original [fennel.vim][2].

## Comparison among Fennel highlight plugins:

### aniseed
![aniseed](./data/aniseed.png)

### tree-sitter
![tree-sitter-fennel](./data/treesitter.png)

### vim-fennel-syntax
![vim-fennel-syntax](./data/example.png)

## Installation

Use your favorite package manager. For example using [Paq][3]:

```lua
require'paq-nvim' {
  'mnacamura/vim-fennel-syntax',
}
```

## Options

For all options, if both global and buffer local ones are defined, the
buffer local one takes precedence.

### `fennel_use_lume`

Enable highlighting for functions provided by [Lume][4].

```vim
let g:fennel_use_lume = 1  " default: 1
```

## Change log

### [0.1][v0.1] (2021-06-13)

* Support Fennel 0.9.2
* Support Lua string literals up to version 5.4
* Support Lua numeric literals up to version 5.4

## License

[MIT](LICENSE)

[1]: https://fennel-lang.org/
[2]: https://github.com/bakpakin/fennel.vim/
[3]: https://github.com/savq/paq-nvim/
[4]: https://github.com/rxi/lume/
[v0.1]: https://github.com/mnacamura/vim-fennel-syntax/tree/v0.1

<!-- vim: set tw=78 spell: -->
