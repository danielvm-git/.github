# Workflow Template Changelog

## 1.0.0 — 2026-07-10

### Added
- Initial versioned release of all 15 workflow templates
- `ci-go.yml` — Go projects (test + lint + security)
- `ci-node.yml` — Node.js projects (lint + typecheck + test)
- `ci-python.yml` — Python projects (lint + test)
- `ci-python-uv.yml` — Python projects with uv package manager
- `ci-python-matrix.yml` — Multi-version Python matrix
- `ci-rust.yml` — Rust projects (clippy + test)
- `ci-shell.yml` — Shell/CLI projects (shellcheck + bats)
- `ci-static-site.yml` — Static sites (lint + build)
- `ci-swift.yml` — Swift projects
- `ci-vue-spa.yml` — Vue SPA projects (lint + typecheck + test + build)
- `ci-monorepo.yml` — Multi-language monorepos
- `codeql-python.yml` — CodeQL analysis for Python
- `codeql-javascript.yml` — CodeQL analysis for JavaScript/TypeScript
- `deploy-pages-mkdocs.yml` — GitHub Pages via MkDocs
- `deploy-pages-starlight.yml` — GitHub Pages via Astro Starlight
- `release-branch.yml` — Pre-land verification (preflight + conventional commits)

### Security baseline
All templates include: `permissions: contents: read`, `timeout-minutes`, `concurrency` with `cancel-in-progress: true`, and pinned `ubuntu-22.04` runner.

### Companion files
- `.properties.json` per template — GitHub Actions tab picker
- `scripts/audit-template-versions.sh` — portfolio-wide version check
- `scripts/validate-templates.sh` — yamllint + schema validation
