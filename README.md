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

Use your favorite package manager. For example in [Paq][4]:

```lua
require'paq-nvim' {
  'mnacamura/vim-fennel-syntax',
}
```

## Options

For all options, if both global and buffer local ones are defined, the
buffer local one takes precedence.

### `fennel_use_lume`

Enable highlighting for functions provided by [Lume][3].

```vim
let g:fennel_use_lume = 1  " default: 1
```

## License

[MIT](LICENSE)

[1]: https://fennel-lang.org/
[2]: https://github.com/bakpakin/fennel.vim/
[3]: https://github.com/rxi/lume/
[4]: https://github.com/savq/paq-nvim/

<!-- vim: set tw=78 spell: -->
