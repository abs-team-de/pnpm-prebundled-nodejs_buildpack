# pnpm-prebundled-nodejs_buildpack

A custom Cloud Foundry buildpack for SAP BTP that deploys Node.js applications with pre-bundled dependencies from pnpm monorepos. It provides the Node.js runtime and validates the application structure — but deliberately skips `npm install` / `pnpm install` at staging time.

Designed for teams using `pnpm deploy` to create self-contained, hermetic application bundles from pnpm workspaces. All dependencies are resolved and bundled locally (or in CI). Node.js and pnpm runtimes are downloaded during staging (and cached), but no `npm install` / `pnpm install` is ever executed — staging requires zero network access to npm registries for dependency resolution.

## Features

- **Zero install at staging** — no `npm install`, no `pnpm install`; Node.js and pnpm runtimes are downloaded (and cached) but no dependency resolution occurs
- **pnpm workspace aware** — validates the flat `node_modules` structure produced by `pnpm deploy`
- **Node.js version resolution** — reads `engines.node` from `package.json`; supports exact versions (`20.18.0`), major (`20`), major.minor (`20.18`), `.x` wildcards (`20.x`, `20.18.x`), and prefix operators (`>=20`, `^20.18.0`, `~20.18.0`). Complex ranges (e.g. `>=18 <21`, `18 || 20`) are **not** supported
- **pnpm version resolution** — reads `packageManager` field from `package.json`
- **Automatic memory tuning** — sets `--max-old-space-size` to 75% of the container memory limit
- **Symlink detection** — catches accidental use of `pnpm install` instead of `pnpm deploy`
- **Dependency smoke test** — verifies at least one dependency resolves before the app starts
- **Staging cache** — Node.js and pnpm downloads are cached between deployments

## Usage

Reference this buildpack by its GitHub URL in your `mta.yaml`:

```yaml
modules:
  - name: srv
    type: nodejs
    path: deploy/srv
    build-parameters:
      builder: custom
      commands: []
    parameters:
      buildpacks:
        - https://github.com/abs-team-de/pnpm-prebundled-nodejs_buildpack.git#v1.0.0
      memory: 512M
      disk_quota: 1024M
      command: node src/server.js
```

## Prerequisites

Your application must be packaged with `pnpm deploy` before building the MTAR:

```bash
# From the monorepo root
pnpm deploy --filter=@myorg/srv --prod ./deploy/srv
```

This produces a standalone directory with a flat, real (non-symlinked) `node_modules`. That directory is what goes into the MTAR.

## Expected Application Structure

```
deploy/srv/
├── package.json          # Must contain "engines.node" and/or "packageManager"
├── node_modules/         # Flat, no symlinks — produced by pnpm deploy
│   ├── @myorg/shared-lib/
│   ├── express/
│   └── ...
└── src/
    └── server.js
```

## Configuration

| Source | Field | Example | Purpose |
|--------|-------|---------|---------|
| `package.json` | `engines.node` | `">=20.18.0"` | Node.js version to install |
| `package.json` | `packageManager` | `"pnpm@9.15.4"` | pnpm version to install |
| Environment | `NODE_OVERRIDE_VERSION` | `20.18.0` | Override Node.js version |
| Environment | `PNPM_OVERRIDE_VERSION` | `9.15.4` | Override pnpm version |

## Staging Output

```
-----> [pnpm-prebundled] Supply phase starting
       Node.js version: v20.18.0 (requested: '>=20.18.0')
       pnpm version:    v9.15.4
-----> [pnpm-prebundled] Downloading Node.js v20.18.0
-----> [pnpm-prebundled] Supply phase complete
       node v20.18.0
-----> [pnpm-prebundled] Finalize phase starting
-----> [pnpm-prebundled] Validating pre-bundled application structure...
       App name: @myorg/srv
       node_modules: 142 top-level packages
       Start script: node src/server.js
       Dependency smoke test passed (resolved '@sap/cds')
-----> [pnpm-prebundled] Validation passed — application is ready
-----> [pnpm-prebundled] No pnpm install executed. Pre-bundled dependencies will be used as-is.
```

## Repository Structure

```
pnpm-prebundled-nodejs_buildpack/
├── bin/
│   ├── detect              # Matches apps with package.json + node_modules
│   ├── supply              # Installs Node.js and pnpm runtimes
│   ├── finalize            # Validates the pre-bundled structure
│   └── release             # Provides default start command
├── lib/
│   └── utils.sh            # Shared helpers: logging, version resolution
├── LICENSE
└── README.md
```

## Why Not the Standard nodejs_buildpack?

The Cloud Foundry `nodejs_buildpack` always runs `npm install` or `npm rebuild`
during staging. This behavior is compiled into the Go binary and cannot be
disabled via configuration. On SAP BTP, `cf create-buildpack` is not available
to customers, so forking and uploading a modified version is not an option either.

This buildpack solves both problems: it's referenced by GitHub URL (no upload
needed) and it never runs any package manager install step.

## Compatibility

- **CF Stack**: cflinuxfs4 (Ubuntu 22.04)
- **Node.js**: Any version available at nodejs.org/dist (default: 20.18.0)
- **pnpm**: Any version published to npmjs.org (default: 9.15.4)
- **SAP BTP**: Tested on SAP BTP Cloud Foundry multi-environment subaccounts

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Security

See [SECURITY.md](SECURITY.md) for vulnerability reporting.

## License

[Apache-2.0](LICENSE)
