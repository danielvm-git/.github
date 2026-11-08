## 4.4.1 — 2026-11-08

### Fix: Template P0 violations; canonical layout is the copy-once pair

The owner decision of 2026-11-08: every repo uses the copy-once pair `test-build-release.yml` + `deploy.yml`. `deploy.yml` runs on `workflow_run` of the pipeline, gated on `conclusion == 'success'` and `head_branch == 'main'`. A thin `ci-cd.yml` that calls reusable workflows is not the pattern. Docs and README templates now say so.

#### Fixed
- **`codeql.yml` 2.0.1, `codeql-javascript.yml` 1.0.1** — `github/codeql-action/{init,analyze}` pinned to the `v3.39.3` commit SHA; `actions/checkout` pinned to the `v7.0.0` commit SHA (template and mirror).
- **`deploy-fullstack.yml` 4.1.1** — `bigbase-deploy` pinned to the `v1` commit SHA (was `@main`), built-in check skipped with `skip_health_check: true`, and a separate `Health check` step added that honours `health_check_expected_body` (template and mirror).
- **`.github/workflows/template-drift-audit.yml`** — the audit exit code is captured inside `if`, so a failing audit no longer ends the step under `bash -e` before the issue is created; `gh issue update` (not a command) is now `gh issue edit`.
- **`scripts/audit-template-versions.sh`** — `((TOTAL++))` returned 1 on the first repo and ended the script under `set -e`; counters now use `$((x + 1))`.

#### Removed
- **`scripts/migration-check.py`** — counted `ci-cd-*` files as migrated and `deploy.yml` as old, the inverse of the canonical layout. Grimoire's `ci-layout` conformance rule replaces it.

---

## 4.4.0 — 2026-11-04

### New template: `test-build-release-godot.yml` (Godot 4.x)

Adds the missing stack to the portfolio: Godot 4.x / GDScript projects.

#### Added
- **`test-build-release-godot.yml`** + `workflow-templates/test-build-release-godot.yml` (mirrored, same version header) and `.properties.json` for the UI template catalog.
- Inputs: `godot_version` (default `4.7.0`), `project_dir` (default `game`), `export_preset` (default empty = no macOS export), `export_path`, `release_tool` (default `big-release`), `bootstrap_gate` (passes `--bootstrap` to a project's `scripts/preflight.sh`).
- Jobs `test → verify → build → release`, plus an optional macOS `export` job.

#### Design decisions
- **The project owns its gate.** `test` runs `bash scripts/preflight.sh` when present (lint, format, strict typing, GUT, PII audit, trace), so a Godot repo's own conventions stay in the repo instead of leaking into the shared workflow.
- **Release never waits on macOS.** `build` is a fast `ubuntu-22.04` job that emits the `deploy-meta.json` boundary artifact (`app_type: godot`); the macOS `export` job runs in parallel and attaches the exported bundle to the release big-release already published. A macOS queue delay must never delay a version.
- **`big-release` is the default** `release_tool`, with the same curl install, `health` + `validate` pre-steps, and the GIT identity env the canaries use.
- **Post-release honesty guard** — the release job fails when a `feat|fix|perf` commit produced no new tag, closing the silent no-op mode.
- Job-scoped `permissions` only (Issue #34), SHA-pinned actions (including `chickensoft-games/setup-godot@v2.4.0`), `ubuntu-22.04` runners, `cancel-in-progress: true`.

---

# Workflow Template Changelog

## 4.3.1 — 2026-11-04

### Fix: Job-scoped permissions on `test-build-release-*` reusable workflows (Issue #34)

Removed the workflow-level `permissions: contents: read` ceiling from all `test-build-release-*.yml` templates and `.github/workflows/test-build-release-*.yml` reusable mirrors, moving `permissions: contents: read` into each non-release job (`test`, `build`, `lint`, `verify`, and docs-only `release`). This preserves least-privilege on CI/build jobs while allowing the `release` job (`contents: write`, `issues: write`, `pull-requests: write`) to inherit write permissions from `workflow_call` callers without triggering `startup_failure`.

#### Files changed
- `workflow-templates/test-build-release-*.yml` and `.github/workflows/test-build-release-*.yml` (fullstack, go, monorepo, node, pages-mkdocs, pages-starlight, php, python, static, swift)
- `scripts/validate-templates.sh`

---

## 4.3.0 — 2026-11-04

### Static template: production-ready `big-release` path (Issue #40)

Brings `test-build-release-static.yml` (bumped `4.1.1 → 4.2.0`) to parity with the `bigbase-canary-*` and `big-dock-locker-site` reference setups.

#### Added
- **Git identity for `big-release`** — sets `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, `GIT_COMMITTER_NAME`, and `GIT_COMMITTER_EMAIL` (`big-release-bot <big-release-bot@danielvm-git.github.io>`) on the `Run big-release` step so the `git` plugin can tag and commit without `exit status 128: Committer identity unknown`.
- **Post-release `VERSION` sync step** — adds `Update VERSION file` after `Run big-release` to read the latest tag (`git describe --tags --abbrev=0`), write `VERSION`, and commit/push `chore(release): update VERSION to $NEW_VER [skip ci]`.
- **`node_version` input (default `"24"`)** — adds `node_version` input on `workflow_call` and defaults all jobs (`test`, `build`, `release`) to Node 24.
- **`CHANGELOG.md` header contract documentation** — documents that `big-release`'s changelog plugin requires `# Changelog` followed by `## [Unreleased]` and `## [<version>]` headers.

#### Changed
- **`release_tool` default** — defaults to `big-release` (with `env.RELEASE_TOOL` fallback so copied standalone workflows also run `big-release` out of the box).
- **Refreshed action SHA pins** — `actions/checkout` updated to `3d3c42e5aac5ba805825da76410c181273ba90b1` (`v7.0.1`) and `actions/setup-node` to `949feb2413d6458794dcd2491c4babbbce0c15c1` (`v7.1.0`).

#### Files changed
- `workflow-templates/test-build-release-static.yml` (`4.1.1 → 4.2.0`)
- `.github/workflows/test-build-release-static.yml` (`4.1.1 → 4.2.0`)

---

## 4.2.1 — 2026-10-29

### Fix: Conventional Commits check rejected every commit on pull requests

The verify job read `git log origin/main..HEAD --oneline`, which prefixes each line with the
short SHA, so `^(feat|fix|...)` never matched and any PR with a commit failed
(`FAIL: ac26a82 feat: valid conventional commit`). Push-to-`main` runs passed only because
the range was empty. Found by `danielvm-git/big-remote-control` while adopting the Swift template.

#### Fixed
- **Commit subject check** — reads `--format=%s` (subject only) instead of `--oneline`.
- **Merge-commit skip** — matches `^Merge ` (the subject) instead of `^[0-9a-f]+ Merge `.

#### Files changed
- `workflow-templates/test-build-release-*.yml` and `.github/workflows/test-build-release-*.yml`
  (fullstack, go, monorepo, node, pages-mkdocs, pages-starlight, php, python, static, swift) — patch bump
- `scripts/check-conventional-commits.sh`
- `docs/INFRA-ARCHITECTURE.md`

#### Consumers
Repos that copied a template: replace `--oneline` with `--format=%s` in the
"Check Conventional Commits" step. Reusable-workflow callers get the fix from `@main`.

## 4.2.0 — 2026-07-25

### Monorepo template: subdirectory SPA support + governance hooks

Targeted improvements to `test-build-release-monorepo.yml` for hybrid apps (Python backend + Node SPA in subdirectory). Addresses Discussion #32 (`big-bolao` migration).

#### Added
- **`node_subdir` input** — route Node steps to a subdirectory (e.g. `web/`). Updates `hashFiles()` checks, `npm --prefix`, and `cache-dependency-path`. Default empty = root.
- **`pre_test` input** — shell command(s) run after preflight, before any lint/test. For governance scripts (`check_scoring_tables.py`, coverage thresholds).
- **`post_test` input** — shell command(s) run after all tests, before build. For extra gates or reporting.
- **`pre_build` input** — shell command(s) run after `deploy-meta.json` write. For asset generation.
- **`post_build` input** — shell command(s) run after artifact upload. For auto-commit of build output (`web/dist/`).

#### Fixed
- **`pytest --if-present`** — replaced invalid pytest flag with a `find`-based file-existence check. Pytest now only runs when `test_*.py` or `*_test.py` files exist.

#### Files changed
- `workflow-templates/test-build-release-monorepo.yml`
- `.github/workflows/test-build-release-monorepo.yml`

#### Consumer example (big-bolao pattern)

```yaml
jobs:
  ci:
    uses: danielvm-git/.github/.github/workflows/test-build-release-monorepo.yml@v2
    with:
      node_subdir: "web"
      pre_test: "python scripts/check_scoring_tables.py"
      post_test: "coverage report --fail-under=80"
      post_build: "git add web/dist && git commit -m 'chore: update dist'"
    secrets: inherit
  deploy:
    needs: ci
    uses: danielvm-git/.github/.github/workflows/deploy-monorepo.yml@v2
    with:
      site_url: "https://my-app.bigbase.click"
      ci_run_id: ${{ github.run_id }}
    secrets: inherit
```

---

## 4.0.0 — 2026-07-25

### Reusable workflow conversion

All 17 workflow templates now support `workflow_call` triggers alongside their original triggers. This enables the reusable workflow model (`uses: danielvm-git/.github/.github/workflows/<name>@v2`) in addition to the existing copy-once model.

- **CI templates** (9 files): `test-build-release-{node,go,python,static,swift,monorepo,pages-mkdocs,pages-starlight,php}.yml` — added `workflow_call` trigger with optional `site_url` input (BigBase stacks) or empty inputs (pages/swift stacks).
- **Deploy templates** (8 files): `deploy-{node,go,python,static,php,monorepo,pages-mkdocs,pages-starlight}.yml` — added `workflow_call` trigger with optional `site_url` and `ci_run_id` inputs. Artifact download uses `ci_run_id` input with fallback to `workflow_run.id` for backward compat.
- **Dual-trigger:** all templates keep their original triggers (`push`/`pull_request` for CI, `workflow_run` for deploy) — existing copied files continue to work unchanged.
- **`if` guard update:** deploy jobs now accept `workflow_call` events in addition to successful `workflow_run` events on `main`.
- **Validation:** `validate-templates.sh` now requires `workflow_call:` in every template.
- **Version bump:** all templates bumped from 3.x to 4.0.0 to signal the structural change.

Consumer workflow example:
```yaml
jobs:
  ci:
    uses: danielvm-git/.github/.github/workflows/test-build-release-node.yml@v2
    with:
      site_url: "https://my-app.bigbase.click"
    secrets: inherit
  deploy:
    needs: ci
    uses: danielvm-git/.github/.github/workflows/deploy-node.yml@v2
    with:
      site_url: "https://my-app.bigbase.click"
      ci_run_id: ${{ github.run_id }}
    secrets: inherit
```

## 3.1.2 — 2026-07-25

### Automated drift detection

- **Scheduled drift audit:** added `.github/workflows/template-drift-audit.yml` — runs `scripts/audit-template-versions.sh` every Monday 09:00 UTC and opens a `template-drift` labelled issue if any portfolio repo is out of date. The issue auto-closes when drift is resolved. Also supports `workflow_dispatch`.
- `scripts/audit-template-versions.sh` already existed as a standalone check; this wraps it in CI.

## 3.1.1 — 2026-07-25

### PHP catalog + health-check resilience fix

- **PHP catalog:** added `test-build-release-php.yml` + `deploy-php.yml` (+ `.properties.json`), the fifth stack pair. `bigbase-deploy`'s `app_type: php` was already implemented server-side (`components/deploy/engine.go`) but had never been exercised through a real CI/CD pipeline — proven green against `bigbase-canary-php` (2026-07-25), the first-ever real deploy of this app_type.
- **`bigbase-deploy-contract.md`:** `app_type` table now lists `php` and updates `node`'s row from "not yet exercised live" to "exercised live 2026-07-25".
- **Health check false-negative fix:** the `Health check` step's `curl` call in all `deploy-*.yml` templates (go/node/python/static/monorepo/php) is no longer fatal on a transient connection-level failure (SSL handshake not ready, DNS not yet propagated) — `curl ... || echo "000"` lets the existing retry loop handle it like any other non-2xx/3xx result instead of aborting the whole step under `set -e` on attempt 1. Observed twice in the same session as false `Deploy` job failures (`bigbase-canary-go`, `bigbase-canary-node`) where the actual deployment had succeeded. See `specs/bugs/BUG-2026-07-25-health-check-not-resilient-to-transient-curl-errors.md`.

## 3.0.1 — 2026-07-25

### Checklist gap closure (Phase A)

- **Workflow-visible smoke:** `bigbase-deploy` gains optional `skip_health_check`; BigBase `deploy-{go,node,python,static,monorepo}.yml` set it and run an explicit `Health check` step after deploy
- **SHA pins:** third-party / first-party actions in `test-build-release-*` and `deploy-*` pinned to commit SHAs with version comments (e.g. `actions/checkout@9c091bb… # v7.0.0`)
- **golangci-lint:** action pinned to commit of `v6.5.2`; binary version stays `v1.64.8` (never `latest`)
- **Swift catalog:** added `test-build-release-swift.yml` (+ `.properties.json`); removed leftover `ci-swift.yml` / `ci-cd-swift.yml` (and properties)
- **Docs:** scrubbed `bigbase-deploy@main` → `@v1`; CLI/library `deploy.yml` N/A documented in migration plan; contract documents `skip_health_check`

### Note after merge
Retag `actions/bigbase-deploy` `v1` (or bump pin SHAs in `deploy-*.yml`) so consumers receive `skip_health_check`. Until then, unknown-input warning + double health check is possible if templates pin an older SHA.

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
