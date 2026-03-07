# Changelog

All notable changes to the Azcoin project will be documented in this file. This project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]
- Ongoing improvements to network stability (Example Comment).
- Internal testing for future mobile wallet compatibility (Example Comment).

## [0.2.1] - 2026-03-07
### Added
- Added `CHANGELOG.md` (this file) to get the ball rolling. Almost everything is made up to this point.
- New `cross-compile.sh` script for streamlined builds on Debian and WSL.
- Integrated Compile & Release Checklist for maintainers.

### Changed
- Updated `nMinimumChainWork` and `defaultAssumeValid` for faster initial block download.
- Refreshed assumed blockchain and chain state sizes in `chainparams.cpp`.
- Set `_CLIENT_VERSION_IS_RELEASE` to true in `configure.ac`.

### Fixed
- Resolved minor build warnings on newer GCC versions.

## [0.2.0] - 2025-12-15
### Added
- Support for HD wallet address generation.
- Initial implementation of the Azcoin-specific consensus rules.

### Changed
- Updated checkpoint data to reflect the latest stable block height.

## [0.1.0] - 2025-09-01
### Added
- Initial Azcoin genesis block and network parameters.
- Basic GUI and CLI wallet functionality.
- Seed node integration for initial peer discovery.