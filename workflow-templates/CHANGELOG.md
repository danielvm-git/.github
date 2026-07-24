# Workflow Template Changelog

## 3.0.0 — 2026-07-24

### Split — 9 consolidated templates → test-build-release + deploy pairs

Reverses the single-file `ci-cd-*.yml` consolidation from 2.0.0. Each stack now ships as two templates:

```
test-build-release-<stack>.yml  →  .github/workflows/test-build-release.yml
deploy-<stack>.yml              →  .github/workflows/deploy.yml
```

Deploy runs via `workflow_run` after Test Build Release succeeds on `main`. Deploy concurrency uses `cancel-in-progress: false` so in-flight deploys are never killed by a newer push.

### Added
- `test-build-release-{node,python,go,static,monorepo,swift,pages-mkdocs,pages-starlight}.yml` — test, verify, semantic-release, deploy-meta artifact upload
- `deploy-{node,python,go,static,pages-mkdocs,pages-starlight}.yml` — workflow_run handoff, artifact verify, BigBase or GitHub Pages deploy

### Removed (from catalog over migration window)
- `ci-cd-*.yml` — replaced by the test-build-release + deploy pair per stack
- `ci-*.yml` (standalone CI-only templates) — absorbed into test-build-release templates

### Pipeline pattern
```
test-build-release.yml:  test → verify → semantic-release → upload deploy-meta
deploy.yml:              workflow_run → download artifact → deploy (cancel-in-progress: false)
```

### Checklist alignment
Templates now satisfy the bigpowers solo-dev CI/CD checklist:
- Deploy shielded from cancellation (separate workflow, `cancel-in-progress: false`)
- Artifact handoff via `deploy-meta` JSON (SHA + app_type) consumed by `bigbase-deploy`
- `bigbase-deploy` pinned to `@v1`, not `@main`
- `environment: production` on BigBase deploy jobs

### Naming convention
- `test-build-release-<stack>.yml` → copy as `test-build-release.yml`
- `deploy-<stack>.yml` → copy as `deploy.yml`
- `codeql.yml` → optional security scanning (unchanged)

### Security baseline
- **Test Build Release:** `permissions: contents: read`, `timeout-minutes`, `concurrency` with `cancel-in-progress: true`, pinned `ubuntu-22.04` (except Swift templates using `macos-14`)
- **Deploy:** `permissions: contents: read` (+ `pages: write`, `id-token: write` for GitHub Pages), `concurrency` with `cancel-in-progress: false`, pinned `ubuntu-22.04`

### Correction
2.0.0 claimed "Conditional BigBase deploy (skips if no secrets configured)" — no such condition exists. Deploy runs when Test Build Release succeeds; missing secrets fail at the `bigbase-deploy` validation step.

### Companion files
- `.properties.json` per template — GitHub Actions tab picker
- `scripts/audit-template-versions.sh` — portfolio-wide version check
- `scripts/validate-templates.sh` — yamllint + schema + concurrency policy validation
- `workflows/test-build-release.yml` — dogfood validation workflow for this repo

## 2.0.0 — 2026-07-11

### Consolidated — 16 templates → 9 templates

Based on lean/CI/CD principles from the Toyota Way, Continuous Integration (Duvall), and Continuous Delivery (Humble & Farley). Every template is now a complete pipeline with 4 stages: `ci → verify → semantic-release → deploy`.

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
ci → verify → semantic-release → deploy
```
- **ci**: Language-specific lint, typecheck, test, build + artifact upload
- **verify**: Preflight + conventional commits + no AI attribution (from release-branch.yml)
- **semantic-release**: Version bump, changelog, GitHub release (main branch only)
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
