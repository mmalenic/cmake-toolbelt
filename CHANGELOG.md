# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.3](https://github.com/mmalenic/cmake-toolbelt/compare/v0.3.2...v0.3.3) (2025-06-07)


### Bug Fixes

* auto literal codegen ([#7](https://github.com/mmalenic/cmake-toolbelt/issues/7)) ([6ef0503](https://github.com/mmalenic/cmake-toolbelt/commit/6ef0503f12073b7442e0fc595a87edf714db70bb))
* do not perform regex for empty line ending ([2c4fd05](https://github.com/mmalenic/cmake-toolbelt/commit/2c4fd0582d7c152f1990c46a0b8069394090f8e2))

## [0.3.2](https://github.com/mmalenic/cmake-toolbelt/compare/v0.3.1...v0.3.2) (2025-04-18)


### Bug Fixes

* replace all special characters when creating include guard in toolbelt_embed ([1a38ea7](https://github.com/mmalenic/cmake-toolbelt/commit/1a38ea7e09a16ac526f49fcf17410c1273c69a0c))

## [0.3.1](https://github.com/mmalenic/cmake-toolbelt/compare/v0.3.0...v0.3.1) (2025-04-12)


### Bug Fixes

* bump version on docs ([0a880d9](https://github.com/mmalenic/cmake-toolbelt/commit/0a880d91b0eac449580ab404a18e9b78ea2289dc))
* set version in conf.py ([4067600](https://github.com/mmalenic/cmake-toolbelt/commit/4067600847787468de4a82173f5a7b2f02d74da1))
* update version in CMakeLists.txt ([6e63558](https://github.com/mmalenic/cmake-toolbelt/commit/6e63558f5e12353a826e52fb60a0f3a84fb2673f))

## [0.3.0](https://github.com/mmalenic/cmake-toolbelt/compare/v0.2.0...v0.3.0) (2024-10-06)


### ⚠ BREAKING CHANGES

* remove `enable_testing` from `toolbelt_setup_gtest` as it should be used from calling code

### Bug Fixes

* remove `enable_testing` from `toolbelt_setup_gtest` as it should be used from calling code ([03debf2](https://github.com/mmalenic/cmake-toolbelt/commit/03debf29a2cc80b6006ea964c6762b4cb1e7b168))

## [0.2.0] - 2023-09-28

### Fixed

- Changed incorrectly named `setup_gtest` function to `toolbelt_setup_gtest`.

## [0.1.1] - 2023-09-22

### Fixed

- Docs describing how to fetch content to use the project

## [0.1.0] - 2024-09-18

### Added

- Initial release

[unreleased]: https://github.com/mmalenic/cmake-toolbelt/compare/0.2.0...HEAD
[0.2.0]: https://github.com/mmalenic/cmake-toolbelt/compare/v0.1.1...0.2.0
[0.1.1]: https://github.com/mmalenic/cmake-toolbelt/compare/v0.1.0...0.1.1
[0.1.0]: https://github.com/mmalenic/cmake-toolbelt/releases/tag/v0.1.0
