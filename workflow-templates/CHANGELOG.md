# Workflow Template Changelog

## 2.0.0 — 2026-07-11

### Consolidated — 16 templates → 9 templates

Based on lean/CI/CD principles from the Toyota Way, Continuous Integration (Duvall), and Continuous Delivery (Humble & Farley). Every template is now a complete pipeline with 3 stages: `ci → verify → deploy`.

### Added
- `ci-cd-node.yml` — Node.js pipeline (replaces ci-node.yml)
- `ci-cd-python.yml` — Python pipeline (replaces ci-python.yml, ci-python-uv.yml, ci-python-matrix.yml)
- `ci-cd-go.yml` — Go pipeline (replaces ci-go.yml)
- `ci-cd-static.yml` — Static site pipeline (replaces ci-static-site.yml, ci-vue-spa.yml)
- `ci-cd-swift.yml` — Swift/macOS pipeline (replaces ci-swift.yml)
- `ci-cd-pages-mkdocs.yml` — MkDocs docs pipeline (replaces deploy-pages-mkdocs.yml)
- `ci-cd-pages-starlight.yml` — Starlight docs pipeline (replaces deploy-pages-starlight.yml)
- `ci-cd-monorepo.yml` — Multi-language pipeline (replaces ci-monorepo.yml, ci-shell.yml, ci-rust.yml)
- `codeql.yml` — Unified CodeQL (replaces codeql-javascript.yml, codeql-python.yml)

### Removed
- `ci-python-uv.yml` — merged into ci-cd-python.yml
- `ci-python-matrix.yml` — merged into ci-cd-python.yml
- `ci-rust.yml` — merged into ci-cd-monorepo.yml
- `ci-shell.yml` — merged into ci-cd-monorepo.yml
- `ci-vue-spa.yml` — merged into ci-cd-static.yml
- `release-branch.yml` — absorbed into all ci-cd-*.yml verify jobs
- `codeql-python.yml` — merged into codeql.yml

### Pipeline pattern
Each `ci-cd-*.yml` template follows:
```
ci → verify → deploy
```
- **ci**: Language-specific lint, typecheck, test, build + artifact upload
- **verify**: Preflight + conventional commits + no AI attribution (from release-branch.yml)
- **deploy**: Conditional BigBase deploy (skips if no secrets configured)

### Naming convention
- `ci-cd-<language>.yml` → full pipeline with BigBase deploy
- `ci-cd-pages-<framework>.yml` → docs pipeline with GitHub Pages deploy
- `ci-cd-monorepo.yml` → multi-language pipeline
- `codeql.yml` → optional security scanning

### Security baseline
All templates include: `permissions: contents: read`, `timeout-minutes`, `concurrency` with `cancel-in-progress: true`, and pinned `ubuntu-22.04` runner (except ci-cd-swift.yml which uses macos-14).

### Companion files
- `.properties.json` per template — GitHub Actions tab picker
- `scripts/audit-template-versions.sh` — portfolio-wide version check
- `scripts/validate-templates.sh` — yamllint + schema validation

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
