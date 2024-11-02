<!-- panvimdoc-ignore-start -->

# vim-fennel-syntax

[![CI][ci-badge]][ci-jobs]
[![Release][release-badge]][release-list]
[![Fennel][fennel-badge]][fennel-homepage]

[ci-badge]: https://img.shields.io/github/actions/workflow/status/m15a/vim-fennel-syntax/ci.yml?logo=github&label=CI&style=flat-square
[ci-jobs]: https://github.com/m15a/vim-fennel-syntax/actions/workflows/ci.yml
[release-badge]: https://img.shields.io/github/release/m15a/vim-fennel-syntax.svg?style=flat-square
[release-list]: https://github.com/m15a/vim-fennel-syntax/releases
[fennel-badge]: https://img.shields.io/badge/Fennel-v1.5.1-fff3d7.svg?style=flat-square
[fennel-homepage]: https://fennel-lang.org/

Yet another Vim syntax highlighting plugin for [Fennel][1].

![Screenshot](_assets/example.png)

This is a fork from the original [fennel.vim][2].

## Features

- **100% Vim script**: Both Vim and Neovim users can enjoy this plugin.
- **Attentive highlighting**: Hash function literal `#(+ $1 $2)`,
    shebang line `#!/usr/bin/env fennel`, and more.
- **Granular Lua version support**: Depending on your Lua version, it
    highlights literals and keywords differently, so that you can easily
    find syntax errors relevant to Lua version difference [^1].

[^1]: For example, hex numeric literal with exponent such as `0xA23p-4`
is supported by Lua 5.2 or later.

## Requirements

It would work with any recent or even older version of Vim/Neovim.

## Installation

Use any Vim/Neovim package manager. An example using [Paq][3] for
Neovim:

```lua
require'paq' {
  ..., -- other plugins
  'm15a/vim-fennel-syntax',
  ..., -- other plugins
}
```

<!-- panvimdoc-ignore-end -->

<!-- panvimdoc-include-comment

```vimdoc
Maintainer: NACAMURA Mitsuhiro <m15@m15a.dev>
URL: https://github.com/m15a/vim-fennel-syntax
License: MIT
```

-->

## Configuration

This plugin will automatically configure most options for your
environment. To configure options manually, you can use the following
global/buffer-local variables.

### Options

| Option                                    | Description                        | Type   | Default value |
| :-                                        | :-                                 | :-     | :-            |
| [fennel_lua_version](#fennel_lua_version) | Lua version to highlight literals. | string | auto-detected |
| [fennel_use_luajit](#fennel_use_luajit)   | Highlight LuaJIT extentions.       | bool   | auto-detected |
| [fennel_use_lume](#fennel_use_lume)       | Highlight Lume keywords.           | bool   | `1`           |

#### `fennel_lua_version`

Highlight literals and keywords for the given Lua version. It supports
`5.1`, `5.2`, `5.3`, and `5.4`. Unless configured manually, it will be
inferred automatically by invoking `lua -v`.

```vim
let g:fennel_lua_version = '5.4'
```

Override it by setting buffer local `b:fennel_lua_version`.

> [!NOTE]
> If neither `g:fennel_lua_version` nor `b:fennel_lua_version` is set
> and `lua` is not found in your `PATH`, it defaults to `5.1`.

#### `fennel_use_luajit`

Highlight literals and keywords extended in [LuaJIT][5]. Unless
configured manually, it will be inferred automatically by invoking
`lua -v`.

```vim
let g:fennel_use_luajit = 0
```

Override it by setting buffer local `b:fennel_use_luajit`.

> [!NOTE]
> If neither `g:fennel_use_luajit` nor `b:fennel_use_luajit` is set
> and `lua` (LuaJIT) is not found in your `PATH`, it defaults to `0`.

#### `fennel_use_lume`

Highlight keywords provided by [Lume][4]. It defaults to `1`.

```vim
let g:fennel_use_lume = 1
```

Override it by setting buffer local `b:fennel_use_lume`.

<!-- panvimdoc-ignore-start -->

## License

[MIT](LICENSE)

<!-- panvimdoc-ignore-end -->

[1]: https://fennel-lang.org/
[2]: https://github.com/bakpakin/fennel.vim/
[3]: https://github.com/savq/paq-nvim/
[4]: https://github.com/rxi/lume/
[5]: https://luajit.org/extensions.html

<!-- vim: set tw=72 spell nowrap: -->
