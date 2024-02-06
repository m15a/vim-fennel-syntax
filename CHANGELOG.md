# Changelog

## Unreleased

### Added

- More granular highlighting for string escape sequences:
  - `\z` and `\x..` are supported by Lua>=5.2 or LuaJIT, highlighted as error otherwise.
  - `\u{..}` is supported by Lua>=5.3, highlighted as error otherwise.
- Support `accumulate` macro.

### Fixed

- Remove highlight for `pick-args` since it has been deprecated (Fennel 0.10.0)

## [0.2][v0.2] (2021-06-20)

### Added

- Option `{g,b}:fennel_lua_version`.
- Option `{g,b}:fennel_use_luajit`.

### Fixed

- Correct highlight for string/numeric literals for each Lua version.
- Add missing `\<CR>` in string literal.
- Fix `\ddd` in string literal.

## [0.1][v0.1] (2021-06-13)

### Added

- Support Fennel 0.9.2.
- Support Lua string literals up to version 5.4.
- Support Lua numeric literals up to version 5.4.

[v0.2]: https://github.com/mnacamura/vim-fennel-syntax/tree/v0.2
[v0.1]: https://github.com/mnacamura/vim-fennel-syntax/tree/v0.1