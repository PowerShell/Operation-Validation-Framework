# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.2.1] - 2019-02-15

### Fixed

- [**#36**](https://github.com/PowerShell/Operation-Validation-Framework/pull/36) - Fixed PowerShell version check logic (via [@miketheitguy](https://github.com/miketheitguy))

## [1.2.0] - 2018-10-18

### Added

- Enable cross platform support

## [1.1.0] - 2018-03-13

### Added

- PR12 - Ability to specify parameter overrides to Pester tests (via @devblackops)
- PR16 - Ability to specify Pester tests to execute based on tag(s) (via @devblackops)
- PR25 - Support for parsing Pester tests when the -Fixture parameter is used (via @GitAMBS)
- PR26 - Support for -Path and -LiteralPath parameters to module directories (via @devblackops)

### Fixed

- PR25 - Discover Pester 'Describe' block names when the -Name parameter is used (via @GitAMBS)
- PR29 - Remove Pester 4.0+ warning by using -Show parameter instead of -Quiet. Add -UseBasicParsing parameter to Invoke-WebRequest in tests (via @larssb)
- Fixed #3 where an error would be generated when using Invoke-OperationValidation with the -TestFilePath parameter
  against a Pester test file with a short path.

## [1.0.1] - 2015-12-05

### Changed

- Handle version specific directories.

## [1.0.0] - Unreleased

### Added

- Initial release
