# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][1], and this project adheres
to [Semantic Versioning][2].

[1]: https://keepachangelog.com/en/1.1.0/
[2]: https://semver.org/spec/v2.0.0.html

## [Unreleased]

### Added

- Support for Fennel 1.6.0:
  - Detection for the new macro file extension `.fnlm`.

## [1.1.0] - 2024-11-02

### Added

- Support for Fennel 1.5.1:
  - Literal syntax `.inf`, `-.inf`, `.nan`, and `-.nan`

### Fixed

- Highlighting for quoted `&`, `&as`, `&into`, and `&until` as symbols
- Highlighting for `catch` keyword in `case-try` and `match-try` forms

## [1.0.1] - 2024-02-07

### Fixed

- Special forms indentation: `case`, `case-try`, `match-try`,
  `fcollect`, and `faccumulate`

## [1.0.0] - 2024-02-06

### Removed

- Highlighting for deprecated special forms / operators:
  - `global` (Fennel 1.1.0)
  - `doc` (Fennel 1.0.0; replaced with `,doc`)
  - `pick-args` (Fennel 0.10.0)
  - `require-macros` (Fennel 0.4.0)

### Added

- Support for Fennel 1.4.0:
  - `tail!` and `assert-repl` macros (Fennel 1.4.0)
  - `case`, `case-try`, and `faccumulate` macros (Fennel 1.3.0)
  - `fcollect` macro (Fennel 1.2.0)
  - `&into` and `&until` keywords in loops (Fennel 1.2.0)
  - `match-try` macro (Fennel 1.1.0)
  - `accumulate` macro (Fennel 0.10.0)
- More granular highlighting for string escape sequences:
  - `\z` and `\x..` are supported by Lua>=5.2 or LuaJIT, highlighted as
    error otherwise.
  - `\u{..}` is supported by Lua>=5.3, highlighted as error otherwise.
- Support for `?.`, `comment?`, and `get-scope`

### Fixed

- `&` in identifier is now highlighted as error (Fennel 1.0.0).

## [0.2] - 2021-06-20

### Added

- Option `{g,b}:fennel_lua_version`
- Option `{g,b}:fennel_use_luajit`
- Highlighting for `\<CR>` in string literal

### Fixed

- Highlighting for string/numeric literals for each Lua version
- `\ddd` in string literal

## [0.1] - 2021-06-13

### Added

- Support for Fennel 0.9.2
- Support for Lua string literals up to version 5.4
- Support for Lua numeric literals up to version 5.4

[Unreleased]: https://github.com/m15a/vim-fennel-syntax/compare/v1.1.0...HEAD
[1.1.0]: https://github.com/m15a/vim-fennel-syntax/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/m15a/vim-fennel-syntax/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/m15a/vim-fennel-syntax/compare/v0.2...v1.0.0
[0.2]: https://github.com/m15a/vim-fennel-syntax/compare/v0.1...v0.2
[0.1]: https://github.com/m15a/vim-fennel-syntax/releases/tag/v0.1

<!-- vim: set tw=72 spell nowrap: -->
