## Project title

MyProject — [One-sentence description of what this does and why it exists].

## Motivation

[Why was this built? What problem does it solve?]

---

## Build status

[![Test Build Release](https://github.com/YOUR_ORG/YOUR_REPO/actions/workflows/test-build-release.yml/badge.svg)](https://github.com/YOUR_ORG/YOUR_REPO/actions)

The badge tracks `.github/workflows/test-build-release.yml`, copied from the matching `workflow-templates/test-build-release-<stack>.yml` (with `deploy.yml` beside it). See `docs/how-to/start-new-project.md` §4 in `danielvm-git/.github`.

---

## Tech/framework used

| Tool | Purpose |
|------|---------|
| **[Language]** | [Purpose] |
| **[Framework]** | [Purpose] |

---

## Features

- [Feature 1]
- [Feature 2]
- [Feature 3]

---

## Commands

| Action | Command |
|--------|---------|
| Run | `[cmd]` |
| Test | `[cmd]` |
| Build | `[cmd]` |
| Lint | `[cmd]` |
| Preflight | `[test && lint && build]` |

---

## Installation

```bash
git clone <repo-url>
cd my-project
# install dependencies
```

---

## How to use

1. **Clone** the repo
2. **Install** dependencies
3. **Run** the project

---

## Contribute

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Commit using [Conventional Commits](https://www.conventionalcommits.org/)
4. Push and open a Pull Request

All contributions must pass preflight.

---

## License

MIT — see [LICENSE](./LICENSE) for details.
