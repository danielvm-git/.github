---
feature: Consolidated CI/CD Workflow Templates
status: delivered
specs: []
plans:
  - .mimocode/plans/1783798816295-mighty-cactus.md
branch: feat/consolidated-ci-cd-templates
commits: pending
---

# Consolidated CI/CD Workflow Templates — Final Report

## What Was Built

Reduced the workflow template catalog from 16 separate templates to 9 unified pipelines. Every `ci-cd-*.yml` template now follows a 4-stage pipeline pattern: `ci → verify → semantic-release → deploy`. This eliminates the batch-and-queue waste of separate CI, PR verification, and deploy workflows — one pipeline per repo, one entry in the Actions tab, one continuous flow from commit to deploy.

The redesign is grounded in lean/CI/CD principles from the Toyota Way (one-piece flow), Continuous Integration (Duvall — one build that does everything), and Continuous Delivery (Humble & Farley — the deployment pipeline as one process).

## Architecture

### New Template Structure

```
workflow-templates/
├── ci-cd-node.yml              # Node.js (replaces ci-node.yml)
├── ci-cd-python.yml            # Python (replaces ci-python.yml, ci-python-uv.yml, ci-python-matrix.yml)
├── ci-cd-go.yml                # Go (replaces ci-go.yml)
├── ci-cd-static.yml            # Static sites (replaces ci-static-site.yml, ci-vue-spa.yml)
├── ci-cd-swift.yml             # Swift/macOS (replaces ci-swift.yml)
├── ci-cd-pages-mkdocs.yml      # MkDocs docs (replaces deploy-pages-mkdocs.yml)
├── ci-cd-pages-starlight.yml   # Starlight docs (replaces deploy-pages-starlight.yml)
├── ci-cd-monorepo.yml          # Multi-language (replaces ci-monorepo.yml, ci-shell.yml, ci-rust.yml)
├── codeql.yml                  # Unified CodeQL (replaces codeql-javascript.yml, codeql-python.yml)
├── CHANGELOG.md                # Updated to v2.0.0
└── *.properties.json           # GitHub workflow picker metadata
```

### Pipeline Pattern (4 jobs)

Every `ci-cd-*.yml` template follows:

```
ci → verify → semantic-release → deploy
```

- **ci**: Language-specific lint, typecheck, test, build + artifact upload. Runs on every push and PR.
- **verify**: Preflight + conventional commits + no AI attribution. Absorbed from `release-branch.yml`. Runs on PRs and pushes to main.
- **semantic-release**: Version bump, changelog, GitHub release. Runs only on push to main.
- **deploy**: Conditional BigBase deploy via `bigbase-deploy` action. Runs only on push to main.

### Naming Convention

| Pattern | Meaning | Deploy Target |
|---------|---------|---------------|
| `ci-cd-<language>.yml` | Full pipeline | BigBase (conditional) |
| `ci-cd-pages-<framework>.yml` | Docs pipeline | GitHub Pages |
| `ci-cd-monorepo.yml` | Multi-language pipeline | BigBase (conditional) |
| `codeql.yml` | Optional security | GitHub Security |

### Design Decisions

- **release-branch.yml merges into every template's verify job** — eliminates the separate PR verification workflow that ran alongside CI
- **Python consolidates 3 variants into 1** — default uv, pip and matrix as commented alternatives
- **Shell and Rust merge into monorepo** — edge cases (1-2 repos each) don't justify dedicated templates
- **CodeQL stays separate** — optional per repo, different trigger (weekly schedule)
- **Deploy is conditional** — skips if `BIGBASE_DEPLOY_TOKEN` not configured, so docs-only repos work without secrets
- **Swift stays separate** — needs `macos-14` runner, can't share ubuntu runner

## Usage

### For new projects

1. Go to repo's Actions tab → New workflow
2. Pick `ci-cd-<language>.yml` from the picker
3. Set `APP_TYPE` and `SITE_URL` env vars at top of template
4. Configure `BIGBASE_SITE_ID` and `BIGBASE_DEPLOY_TOKEN` secrets

### For existing projects

Replace old workflow files with the new template:
```bash
# Remove old workflows
rm .github/workflows/ci.yml .github/workflows/release-branch.yml

# Copy new template
cp workflow-templates/ci-cd-node.yml .github/workflows/ci-cd.yml

# Configure
# Edit APP_TYPE and SITE_URL in the workflow file
```

### Trigger a deploy

```bash
gh workflow run ci-cd.yml --ref main
```

## Verification

1. All 9 new `.yml` files pass YAML validation (structure, required fields, timeout-minutes on all jobs)
2. All 9 `.properties.json` files pass JSON validation (name, description, iconName, categories)
3. Every old template accounted for: 7 deleted (merged), 9 replaced (still present for migration)
4. CHANGELOG.md updated to v2.0.0 with full migration mapping
5. README.md, align-existing-repo.md, github-actions-best-practices.md updated to reference new templates

## Journey Log

- [lesson] GitHub Actions doesn't allow `secrets` in job-level `if` conditions — use env vars propagated from earlier jobs
- [lesson] YAML `on` keyword is parsed as Python boolean `True` — validation scripts need custom constructor
- [lesson] The `passthrough_paths` gap in `bigbase-deploy` action blocks big-library and big-bolao from using the shared action — separate fix needed in bigbase repo
