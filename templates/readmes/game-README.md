## Project title

MyGame — A [Godot/Unity/Unreal] game about [one-line description].

## Motivation

[Why does this game exist? What makes it worth playing?]

---

## Build status

[![Test Build Release](https://github.com/YOUR_ORG/YOUR_REPO/actions/workflows/test-build-release.yml/badge.svg)](https://github.com/YOUR_ORG/YOUR_REPO/actions)

The badge tracks `.github/workflows/test-build-release.yml`, copied from the matching `workflow-templates/test-build-release-<stack>.yml` (with `deploy.yml` beside it). See `docs/how-to/start-new-project.md` §4 in `danielvm-git/.github`.

---

## Controls

| Input | Action |
|-------|--------|
| Arrow keys / WASD | Move |
| Space | Jump |
| E | Interact |

---

## Screenshots

> _Include screenshots or GIFs of gameplay, menus, and key moments._

---

## Tech/framework used

| Tool | Purpose |
|------|---------|
| **Godot 4** | Game engine |
| **GDScript** | Scripting language |
| **gdlint** | Code linting |
| **GUT** | Unit testing |

---

## Features

- [Feature 1 — one sentence]
- [Feature 2 — one sentence]
- [Feature 3 — one sentence]

---

## Installation

```bash
# Clone the repo
git clone <repo-url>
cd my-game

# Open in Godot
godot --editor

# Or run directly
godot --path .
```

---

## Commands

| Action | Command |
|--------|---------|
| Lint | `gdlint game/` |
| Test | `godot --headless --path . -s addons/gut/gut_cmdln.gd` |
| Run | `godot --path .` |
| Export | See `export_presets.cfg` |
| Preflight | `gdlint game/ && godot --headless --path . -s addons/gut/gut_cmdln.gd` |

---

## How to use

1. **Clone** the repo
2. **Open** in Godot 4.x
3. **Run** the main scene

---

## Contribute

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Commit using [Conventional Commits](https://www.conventionalcommits.org/)
4. Push and open a Pull Request

---

## License

MIT — see [LICENSE](./LICENSE) for details.
