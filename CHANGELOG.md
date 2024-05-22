# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.1] - 2024-05-22

### Changed

- Indexing wrapper tables with nil will return nil instead of erroring.

## [2.1.0] - 2024-05-22

### Added

- Added length operator to wrapper tables

### Changed

- Changed the fallback behaviour of wrapper tables so missing keys are nil
- Merges add placeholders so empty tables can be tracked

### Fixed

- Fixed iterating over config wrapper tables

## [2.0.2] - 2024-05-19

### Changed

- Improved some of the descriptions in the definitions

### Fixed

- Fixed `auto` so it uses the correct path for loading the lua file
- Fixed some incorrect types in the definitions

## [2.0.1] - 2024-05-19

### Changed

- Retroactively update changelog

## [2.0.0] - 2024-05-19

### Added

- Added a new interface for working with the .cfg file system

### Removed

- Removed all of the previous interface for .toml files

## [1.0.0] - 2024-05-15

### Added

- Initial Thunderstore release.

[unreleased]: https://github.com/SGG-Modding/Chalk/compare/2.1.1...HEAD
[2.1.1]: https://github.com/SGG-Modding/Chalk/compare/2.1.0...2.1.1
[2.1.0]: https://github.com/SGG-Modding/Chalk/compare/2.0.2...2.1.0
[2.0.2]: https://github.com/SGG-Modding/Chalk/compare/2.0.1...2.0.2
[2.0.1]: https://github.com/SGG-Modding/Chalk/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/SGG-Modding/Chalk/compare/1.0.0...2.0.0
[1.0.0]: https://github.com/SGG-Modding/Chalk/compare/83bc308a1a2b20e01b58de57fea4894e8fabc366...1.0.0
