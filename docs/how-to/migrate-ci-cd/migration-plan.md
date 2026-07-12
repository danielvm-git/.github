# CI/CD Migration Plan — Consolidated Templates

> **Date:** 2026-07-11
> **PR:** https://github.com/danielvm-git/.github/pull/11
> **Status:** Ready for per-repo migration

## Background

The `.github` template repo has been redesigned from 16 separate workflow templates to 9 unified CI/CD pipelines. Every `ci-cd-*.yml` template now follows a 4-stage pipeline pattern:

```
ci → verify → semantic-release → deploy
```

- **ci**: Language-specific lint, typecheck, test, build + artifact upload
- **verify**: Preflight + conventional commits + no AI attribution (absorbed from `release-branch.yml`)
- **semantic-release**: Version bump, changelog, GitHub release (main branch only)
- **deploy**: Conditional BigBase deploy via `bigbase-deploy` action

## Migration Scope

### Repos to migrate (10)

| # | Repo | Stack | Current Workflows | Deploy Target | New Template |
|---|------|-------|-------------------|---------------|--------------|
| 1 | `bigbase` | Go + Node.js | ci.yml, codeql.yml, pr-review.yaml, release-deploy.yml | BigBase + SSH | `ci-cd-go.yml` |
| 2 | `bigpowers` | Node.js + Python + docs | agent-locks.yml, agentics-maintenance.yml, docs-site.yml, publish.yml, sync-*.yml | GitHub Pages | `ci-cd-node.yml` + `ci-cd-pages-starlight.yml` |
| 3 | `grimoire` | Python + docs | ci.yml, codeql.yml, deploy.yml, docs.yaml | BigBase + GitHub Pages | `ci-cd-python.yml` + `ci-cd-pages-mkdocs.yml` |
| 4 | `big-bolao` | Node.js + Python | ci-cd.yml, codeql-javascript.yml, codeql-python.yml | BigBase | `ci-cd-node.yml` or `ci-cd-monorepo.yml` |
| 5 | `big-counter` | Python | ci.yaml, codeql.yml, release.yaml | None | `ci-cd-python.yml` |
| 6 | `astrobiologia` | Node.js + docs | ci.yml, deploy-bigbase.yml | BigBase | `ci-cd-static.yml` |
| 7 | `big-library` | Node.js + Python | ci-cd.yml, codeql.yml | BigBase | `ci-cd-monorepo.yml` |
| 8 | `big-olive-books` | Node.js | ci-cd.yml | BigBase | `ci-cd-static.yml` |
| 9 | `big-token-saver` | Node.js + Rust | ci.yml, release.yml | None | `ci-cd-monorepo.yml` |
| 10 | `big-quiqui` | Node.js | lint_and_test.yml, release.yml | None | `ci-cd-node.yml` |

### Repos NOT migrating (special cases)

| Repo | Reason |
|------|--------|
| `bigbase` (deploy) | `release-deploy.yml` uses SSH to Contabo VPS — keep as-is until BigBase self-deploys |
| `bigpowers` (agent workflows) | Agent-generated workflows — don't touch |

## Migration Steps (per repo)

### Step 1: Create feature branch

```bash
cd ~/Developer/<repo>
git checkout -b refactor/consolidate-ci-cd
```

### Step 2: Copy new template

```bash
# From the .github repo:
cp ~/Developer/.github/workflow-templates/ci-cd-<language>.yml .github/workflows/ci-cd.yml
```

### Step 3: Configure

Edit `.github/workflows/ci-cd.yml`:
- Set `APP_TYPE` (static, python, node, go)
- Set `SITE_URL` (https://<slug>.bigbase.click)
- Adjust language-specific steps if needed

### Step 4: Remove old workflows

```bash
# Remove old CI workflow
rm .github/workflows/ci.yml  # or ci.yaml, ci-cd.yml (old)

# Remove old release-branch workflow (if exists)
rm .github/workflows/release-branch.yml  # or release.yaml, release.yml

# Remove old deploy workflow (if exists)
rm .github/workflows/deploy-bigbase.yml  # or deploy.yml

# Keep CodeQL if desired (it's optional)
# rm .github/workflows/codeql.yml
```

### Step 5: Verify

```bash
# Validate YAML
yamllint .github/workflows/ci-cd.yml

# Push and check CI passes
git add -A && git commit -m "refactor: consolidate CI/CD into single pipeline"
git push -u origin refactor/consolidate-ci-cd
```

### Step 6: Open PR

```bash
gh pr create --title "refactor: consolidate CI/CD into single pipeline" --body "..."
```

## Naming Convention

All workflow `name:` fields follow `Function (Scope)` pattern:

| Type | Pattern | Examples |
|------|---------|----------|
| CI | `CI` | `CI` — build/test only |
| CI/CD | `CI/CD` | `CI/CD` — build/test + deploy |
| Deploy | `Deploy (Target)` | `Deploy (BigBase)`, `Deploy (GitHub Pages)` |
| Docs | `Deploy Docs` | `Deploy Docs` — documentation deployment |
| CodeQL | `CodeQL` or `CodeQL (Language)` | `CodeQL`, `CodeQL (JavaScript)`, `CodeQL (Python)` |
| Release | `Release` or `Release (Target)` | `Release`, `Release (BigBase)` |

YAML `name:` field: short, scannable in Actions tab.
Properties `name`: descriptive for GitHub workflow picker (e.g. `CI/CD (Node.js)`).

## Template Selection Guide

| Stack | Template | Notes |
|-------|----------|-------|
| Node.js (static site) | `ci-cd-static.yml` | For Astro, Vue SPA, React SPA |
| Node.js (library/API) | `ci-cd-node.yml` | For npm packages, servers |
| Python | `ci-cd-python.yml` | Default uv, pip as alternative |
| Go | `ci-cd-go.yml` | Includes golangci-lint |
| Swift | `ci-cd-swift.yml` | macOS runner, no deploy yet |
| Multi-language | `ci-cd-monorepo.yml` | Auto-detects Node, Python, Rust, Go, Shell |
| MkDocs docs | `ci-cd-pages-mkdocs.yml` | GitHub Pages deploy |
| Starlight docs | `ci-cd-pages-starlight.yml` | GitHub Pages deploy |
| Security scanning | `codeql.yml` | Optional, set `LANGUAGES` env var |

## Timeline

- [ ] PR #11 merged in `.github` repo
- [ ] bigbase migrated
- [ ] big-library migrated (reference implementation — already uses single pipeline)
- [ ] big-olive-books migrated
- [ ] astrobiologia migrated
- [ ] big-bolao migrated
- [ ] big-counter migrated
- [ ] grimoire migrated
- [ ] big-token-saver migrated
- [ ] big-quiqui migrated
- [ ] bigpowers migrated (agent workflows stay as-is)
- [ ] Old templates deleted from `.github/workflow-templates/`
