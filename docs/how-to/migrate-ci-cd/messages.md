# CI/CD Migration Messages — Per-Repo Walkthroughs

> Ready to send to each repo's developers. Validate before posting.

---

## 1. bigbase

**Repo:** `danielvm-git/bigbase`
**Current:** ci.yml, codeql.yml, pr-review.yaml, release-deploy.yml
**Target:** `ci-cd-go.yml`

Hey! The `.github` template repo just got a major redesign — 16 separate workflow templates consolidated into 9 unified pipelines. Every template now follows a 4-stage pattern: `ci → verify → semantic-release → deploy`.

For `bigbase`, I recommend migrating to `ci-cd-go.yml`. Here's the walkthrough:

### What changes

| Old | New |
|-----|-----|
| `ci.yml` (CI only) | `ci-cd.yml` (CI + verify + deploy) |
| `release-deploy.yml` (SSH deploy) | Keep as-is (BigBase self-deploy) |
| `codeql.yml` | Keep as-is (optional) |
| `pr-review.yaml` | Keep as-is (PR-Agent) |

### Steps

```bash
cd ~/Developer/bigbase
git checkout -b refactor/consolidate-ci-cd

# Copy the new template
cp ~/Developer/.github/workflow-templates/ci-cd-go.yml .github/workflows/ci-cd.yml

# Edit .github/workflows/ci-cd.yml:
# - Set APP_TYPE: go
# - Set SITE_URL: "https://bigbase.click"
# - The ci job already has build, vet, test
# - The lint job already has golangci-lint
# - The verify job adds preflight + conventional commits
# - The deploy job calls bigbase-deploy action

# Remove old CI workflow (the new one replaces it)
rm .github/workflows/ci.yml

# Keep release-deploy.yml (SSH deploy for BigBase itself)
# Keep codeql.yml (security scanning)
# Keep pr-review.yaml (PR-Agent)

# Validate and push
yamllint .github/workflows/ci-cd.yml
git add -A && git commit -m "refactor: consolidate CI/CD into single pipeline"
git push -u origin refactor/consolidate-ci-cd
gh pr create
```

### Key differences

- The new pipeline adds a **verify** job (preflight + conventional commits + no AI attribution)
- Deploy is conditional — only runs on push to main when `BIGBASE_DEPLOY_TOKEN` is set
- `release-deploy.yml` stays for BigBase's own SSH deploy to Contabo

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 2. bigpowers

**Repo:** `danielvm-git/bigpowers`
**Current:** agent-locks.yml, agentics-maintenance.yml, docs-site.yml, publish.yml, sync-*.yml
**Target:** `ci-cd-node.yml` + `ci-cd-pages-starlight.yml`

Hey! The `.github` template repo just got redesigned — 16 templates → 9 unified pipelines.

For `bigpowers`, the agent workflows (agent-locks, agentics-maintenance, sync-*, publish-wiki) should stay as-is — they're agent-generated. But the docs site can be migrated.

### What changes

| Old | New |
|-----|-----|
| `docs-site.yml` | `ci-cd-pages-starlight.yml` |
| Agent workflows | Keep as-is |

### Steps

```bash
cd ~/Developer/bigpowers
git checkout -b refactor/consolidate-ci-cd

# Copy the Starlight template
cp ~/Developer/.github/workflow-templates/ci-cd-pages-starlight.yml .github/workflows/ci-cd-docs.yml

# The template already handles:
# - CI: build docs (npm ci + npm run build in website/)
# - Verify: preflight + conventional commits
# - Deploy: GitHub Pages with retry

# Remove old docs workflow
rm .github/workflows/docs-site.yml

# Keep all agent-generated workflows untouched

yamllint .github/workflows/ci-cd-docs.yml
git add -A && git commit -m "refactor: consolidate docs CI/CD into single pipeline"
git push -u origin refactor/consolidate-ci-cd
gh pr create
```

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 3. grimoire

**Repo:** `danielvm-git/grimoire`
**Current:** ci.yml, codeql.yml, deploy.yml, docs.yaml
**Target:** `ci-cd-python.yml` + `ci-cd-pages-mkdocs.yml`

Hey! The `.github` template repo redesigned — 16 templates → 9 unified pipelines.

For `grimoire`, the Python CI and MkDocs deploy can each become a single pipeline.

### What changes

| Old | New |
|-----|-----|
| `ci.yml` (Python CI) | `ci-cd.yml` (CI + verify, no deploy) |
| `deploy.yml` (BigBase) | Merge into ci-cd.yml deploy job |
| `docs.yaml` (MkDocs → Pages) | `ci-cd-docs.yml` |
| `codeql.yml` | Keep as-is |

### Steps

```bash
cd ~/Developer/grimoire
git checkout -b refactor/consolidate-ci-cd

# Python CI + optional BigBase deploy
cp ~/Developer/.github/workflow-templates/ci-cd-python.yml .github/workflows/ci-cd.yml
# Edit: set APP_TYPE=python, SITE_URL

# MkDocs docs pipeline
cp ~/Developer/.github/workflows/docs.yaml .github/workflows/ci-cd-docs.yml
# Or use the new template:
cp ~/Developer/.github/workflow-templates/ci-cd-pages-mkdocs.yml .github/workflows/ci-cd-docs.yml

# Remove old workflows
rm .github/workflows/ci.yml .github/workflows/deploy.yml .github/workflows/docs.yaml

yamllint .github/workflows/ci-cd.yml .github/workflows/ci-cd-docs.yml
git add -A && git commit -m "refactor: consolidate CI/CD into single pipeline"
git push -u origin refactor/consolidate-ci-cd
gh pr create
```

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 4. big-bolao

**Repo:** `danielvm-git/big-bolao`
**Current:** ci-cd.yml, codeql-javascript.yml, codeql-python.yml
**Target:** `ci-cd-monorepo.yml` or `ci-cd-node.yml`

Hey! The `.github` template repo redesigned — 16 templates → 9 unified pipelines.

For `big-bolao` (Node.js + Python), the monorepo template is the best fit.

### What changes

| Old | New |
|-----|-----|
| `ci-cd.yml` | `ci-cd.yml` (new unified version) |
| `codeql-javascript.yml` | `codeql.yml` (unified) |
| `codeql-python.yml` | Merged into `codeql.yml` |

### Steps

```bash
cd ~/Developer/big-bolao
git checkout -b refactor/consolidate-ci-cd

# Use monorepo template (auto-detects Node + Python)
cp ~/Developer/.github/workflow-templates/ci-cd-monorepo.yml .github/workflows/ci-cd.yml

# Unified CodeQL
cp ~/Developer/.github/workflow-templates/codeql.yml .github/workflows/codeql.yml
# Edit: set LANGUAGES: "javascript,python"

# Remove old workflows
rm .github/workflows/codeql-javascript.yml .github/workflows/codeql-python.yml

yamllint .github/workflows/ci-cd.yml .github/workflows/codeql.yml
git add -A && git commit -m "refactor: consolidate CI/CD into single pipeline"
git push -u origin refactor/consolidate-ci-cd
gh pr create
```

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 5. big-counter

**Repo:** `danielvm-git/big-counter`
**Current:** ci.yaml, codeql.yml, release.yaml
**Target:** `ci-cd-python.yml`

Hey! The `.github` template repo redesigned — 16 templates → 9 unified pipelines.

For `big-counter` (Python), the new template absorbs CI + release into one pipeline.

### What changes

| Old | New |
|-----|-----|
| `ci.yaml` | `ci-cd.yml` (CI + verify) |
| `release.yaml` | Absorbed into verify job |
| `codeql.yml` | Keep as-is |

### Steps

```bash
cd ~/Developer/big-counter
git checkout -b refactor/consolidate-ci-cd

cp ~/Developer/.github/workflow-templates/ci-cd-python.yml .github/workflows/ci-cd.yml
# Edit: set APP_TYPE if deploying, or remove deploy job if not

rm .github/workflows/ci.yaml .github/workflows/release.yaml

yamllint .github/workflows/ci-cd.yml
git add -A && git commit -m "refactor: consolidate CI/CD into single pipeline"
git push -u origin refactor/consolidate-ci-cd
gh pr create
```

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 6. astrobiologia

**Repo:** `danielvm-git/astrobiologia`
**Current:** ci.yml, deploy-bigbase.yml
**Target:** `ci-cd-static.yml`

Hey! The `.github` template repo redesigned — 16 templates → 9 unified pipelines.

For `astrobiologia` (Node.js/Astro static site), the static template is perfect.

### What changes

| Old | New |
|-----|-----|
| `ci.yml` | `ci-cd.yml` (CI + verify + deploy) |
| `deploy-bigbase.yml` | Merged into ci-cd.yml deploy job |

### Steps

```bash
cd ~/Developer/astrobiologia
git checkout -b refactor/consolidate-ci-cd

cp ~/Developer/.github/workflow-templates/ci-cd-static.yml .github/workflows/ci-cd.yml
# Edit: set SITE_URL to https://astrobiologia.bigbase.click

rm .github/workflows/ci.yml .github/workflows/deploy-bigbase.yml

yamllint .github/workflows/ci-cd.yml
git add -A && git commit -m "refactor: consolidate CI/CD into single pipeline"
git push -u origin refactor/consolidate-ci-cd
gh pr create
```

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 7. big-library

**Repo:** `danielvm-git/big-library`
**Current:** ci-cd.yml, codeql.yml
**Target:** `ci-cd-monorepo.yml`

Hey! The `.github` template repo redesigned — 16 templates → 9 unified pipelines.

`big-library` already has a single pipeline (`ci-cd.yml`) which is great. The new template adds a **verify** job (preflight + conventional commits).

### What changes

| Old | New |
|-----|-----|
| `ci-cd.yml` | `ci-cd.yml` (adds verify job) |
| `codeql.yml` | Keep as-is |

### Steps

```bash
cd ~/Developer/big-library
git checkout -b refactor/consolidate-ci-cd

cp ~/Developer/.github/workflow-templates/ci-cd-monorepo.yml .github/workflows/ci-cd.yml
# Edit: keep Node + Go steps, set APP_TYPE and SITE_URL
# Note: passthrough_paths not yet supported by bigbase-deploy action

git add -A && git commit -m "refactor: consolidate CI/CD into single pipeline"
git push -u origin refactor/consolidate-ci-cd
gh pr create
```

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 8. big-olive-books

**Repo:** `danielvm-git/big-olive-books`
**Current:** ci-cd.yml
**Target:** `ci-cd-static.yml`

Hey! The `.github` template repo redesigned — 16 templates → 9 unified pipelines.

`big-olive-books` already has a single pipeline. The new template adds a **verify** job.

### What changes

| Old | New |
|-----|-----|
| `ci-cd.yml` | `ci-cd.yml` (adds verify job) |

### Steps

```bash
cd ~/Developer/big-olive-books
git checkout -b refactor/consolidate-ci-cd

cp ~/Developer/.github/workflow-templates/ci-cd-static.yml .github/workflows/ci-cd.yml
# Edit: set SITE_URL

git add -A && git commit -m "refactor: consolidate CI/CD into single pipeline"
git push -u origin refactor/consolidate-ci-cd
gh pr create
```

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 9. big-token-saver

**Repo:** `danielvm-git/big-token-saver`
**Current:** ci.yml, release.yml
**Target:** `ci-cd-monorepo.yml`

Hey! The `.github` template repo redesigned — 16 templates → 9 unified pipelines.

For `big-token-saver` (Node.js + Rust), the monorepo template auto-detects both.

### What changes

| Old | New |
|-----|-----|
| `ci.yml` | `ci-cd.yml` (CI + verify) |
| `release.yml` | Absorbed into verify job |

### Steps

```bash
cd ~/Developer/big-token-saver
git checkout -b refactor/consolidate-ci-cd

cp ~/Developer/.github/workflow-templates/ci-cd-monorepo.yml .github/workflows/ci-cd.yml
# Edit: remove deploy job if not deploying to BigBase

rm .github/workflows/ci.yml .github/workflows/release.yml

yamllint .github/workflows/ci-cd.yml
git add -A && git commit -m "refactor: consolidate CI/CD into single pipeline"
git push -u origin refactor/consolidate-ci-cd
gh pr create
```

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 10. big-quiqui

**Repo:** `danielvm-git/big-quiqui`
**Current:** lint_and_test.yml, release.yml
**Target:** `ci-cd-node.yml`

Hey! The `.github` template repo redesigned — 16 templates → 9 unified pipelines.

For `big-quiqui` (Node.js), the new template absorbs lint, test, and release into one pipeline.

### What changes

| Old | New |
|-----|-----|
| `lint_and_test.yml` | `ci-cd.yml` (CI + verify) |
| `release.yml` | Absorbed into verify job |

### Steps

```bash
cd ~/Developer/big-quiqui
git checkout -b refactor/consolidate-ci-cd

cp ~/Developer/.github/workflow-templates/ci-cd-node.yml .github/workflows/ci-cd.yml
# Edit: remove deploy job if not deploying to BigBase

rm .github/workflows/lint_and_test.yml .github/workflows/release.yml

yamllint .github/workflows/ci-cd.yml
git add -A && git commit -m "refactor: consolidate CI/CD into single pipeline"
git push -u origin refactor/consolidate-ci-cd
gh pr create
```

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`
