# project-name

One-sentence description of what this crate/binary does.

## Motivation

Why this exists — the problem it solves.

## Build status

[![Test Build Release](https://github.com/YOUR_ORG/YOUR_REPO/actions/workflows/test-build-release.yml/badge.svg)](https://github.com/YOUR_ORG/YOUR_REPO/actions)

The badge tracks `.github/workflows/test-build-release.yml`, copied from the matching `workflow-templates/test-build-release-<stack>.yml` (with `deploy.yml` beside it). See `docs/how-to/start-new-project.md` §4 in `danielvm-git/.github`.

![crates.io](https://img.shields.io/crates/v/CRATE_NAME.svg)

## Tech / framework used

- Rust (edition 2021+)
- Key crates: [list, e.g. `clap`, `tokio`, `serde`]

## Features

- Feature 1
- Feature 2

## Commands

| Action | Command |
|--------|---------|
| Run | `cargo run` |
| Test | `cargo test` |
| Build | `cargo build --release` |
| Lint | `cargo clippy -- -D warnings` |
| Preflight | `cargo clippy -- -D warnings && cargo test && cargo build --release` |

Run `Preflight` before any forward work. It must be green before you branch or merge.

## Installation

```bash
cargo install CRATE_NAME
# or, from source:
git clone https://github.com/danielvm-git/REPO.git && cd REPO
cargo build --release
```

## How to use

```bash
crate-name --flag value
```

## Tests

```bash
cargo test
cargo clippy -- -D warnings
```

## API reference

Link to `cargo doc` output or docs.rs, if published.

## Contribute

See CONTRIBUTING.md.

## Credits

## License

MIT — see LICENSE.
