# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.3.0](https://github.com/abs-team-de/pnpm-prebundled-nodejs_buildpack/compare/v1.2.1...v1.3.0) — 2026-03-16

### Fixed

- `resolve_node_version` now rejects unsupported `engines.node` range expressions (`>=18 <21`, `18 || 20`, `18 - 20`, `*`) with a clear error instead of silently producing an incorrect version
- `bin/release` YAML output now JSON-escapes the start command to handle quotes, backslashes, and shell fragments safely

### Changed

- README: updated usage example from `#v1.0.0` to `#v1.2.1`

## [1.2.1](https://github.com/abs-team-de/pnpm-prebundled-nodejs_buildpack/compare/v1.2.0...v1.2.1) — 2026-03-16

### Fixed

- `profile.d/000_node.sh`: replace `${DEPS_DIR}` placeholder with actual path at staging time so `node` is on PATH at runtime

## [1.2.0](https://github.com/abs-team-de/pnpm-prebundled-nodejs_buildpack/compare/v1.1.0...v1.2.0) — 2026-03-16

### Fixed

- Symlink detection in `bin/finalize` now fails staging (`exit 1`) instead of only warning; prevents broken bundles from deploying
- README: corrected claim that staging requires "no network access" — Node.js and pnpm runtimes are downloaded (and cached) during staging
- README: documented exact supported `engines.node` patterns and noted that complex semver ranges are not supported

### Added

- SHA1 checksum verification for pnpm tarball downloads against npm registry metadata
- Bats test suite (`test/`) with 32 tests covering `detect`, `finalize`, `release`, and `lib/utils.sh`
- GitHub Actions CI workflow (`.github/workflows/ci.yml`)

### Changed

- Symlink detection wording changed from "may indicate" to "indicates" for clarity

## [1.1.0](https://github.com/abs-team-de/pnpm-prebundled-nodejs_buildpack/compare/v1.0.0...v1.1.0) — 2026-03-16

### Added

- SHA256 checksum verification for Node.js tarball downloads against `SHASUMS256.txt`
- `SSL_CERT_DIR=/etc/ssl/certs` default for Node.js >= 20 CA store compatibility
- `WEB_MEMORY=512` and `WEB_CONCURRENCY=1` defaults (parity with official CF nodejs-buildpack)

## [1.0.0](https://github.com/abs-team-de/pnpm-prebundled-nodejs_buildpack/releases/tag/v1.0.0) — 2026-03-16

### Added

- `bin/detect` — matches apps with `package.json` + `node_modules/`
- `bin/supply` — downloads and caches Node.js and pnpm runtimes
- `bin/finalize` — validates pre-bundled application structure (no symlinks, dependency smoke test)
- `bin/release` — provides default start command from `package.json`
- `lib/utils.sh` — shared logging, `read_package_field`, semver version resolution
- Automatic memory tuning via `--max-old-space-size` (75% of container memory)
- `NODE_ENV=production` default via `profile.d`
- Staging cache for Node.js and pnpm downloads
- Apache-2.0 license
- SECURITY.md, CONTRIBUTING.md, issue/PR templates
