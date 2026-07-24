# CI/CD Migration Plan — Split Templates (3.0.0)

> **Date:** 2026-07-24
> **Status:** Ready for per-repo migration
> **Supersedes:** [2026-07-11 consolidated migration plan](./migration-plan-v2-consolidated.md) (single `ci-cd-*.yml` per stack)

## Background

The `.github` template repo has been redesigned from 9 unified `ci-cd-*.yml` pipelines to **two-file pairs** per stack. This aligns with the bigpowers solo-dev CI/CD checklist: deploy runs in a separate workflow with `cancel-in-progress: false`, and CI passes a pinned commit SHA to deploy via artifact handoff.

```
test-build-release.yml:  test → verify → semantic-release → upload deploy-meta
deploy.yml:              workflow_run → download artifact → deploy
```

## Two-file copy-as guidance

Every stack ships two templates. Copy each to a **fixed filename** in the consumer repo — the deploy template hard-codes `workflows: ["Test Build Release"]`, so the upstream workflow name must match.

### Step 1: Pick your stack pair

| Stack | Copy from `.github` repo | Save as in consumer repo |
|-------|--------------------------|--------------------------|
| Node.js (library/API) | `test-build-release-node.yml` + `deploy-node.yml` | `test-build-release.yml` + `deploy.yml` |
| Python | `test-build-release-python.yml` + `deploy-python.yml` | `test-build-release.yml` + `deploy.yml` |
| Go | `test-build-release-go.yml` + `deploy-go.yml` | `test-build-release.yml` + `deploy.yml` |
| Static site | `test-build-release-static.yml` + `deploy-static.yml` | `test-build-release.yml` + `deploy.yml` |
| Swift/macOS | `test-build-release-swift.yml` + *(no deploy yet)* | `test-build-release.yml` |
| Multi-language | `test-build-release-monorepo.yml` + `deploy-monorepo.yml` | `test-build-release.yml` + `deploy.yml` |
| MkDocs docs | `test-build-release-pages-mkdocs.yml` + `deploy-pages-mkdocs.yml` | `test-build-release.yml` + `deploy.yml` |
| Starlight docs | `test-build-release-pages-starlight.yml` + `deploy-pages-starlight.yml` | `test-build-release.yml` + `deploy.yml` |

Optional: add `codeql.yml` unchanged for security scanning.

### Step 2: Copy both files

```bash
STACK=node   # change to match your stack: python, go, static, monorepo, pages-mkdocs, pages-starlight

cp ~/Developer/.github/workflow-templates/test-build-release-${STACK}.yml \
   .github/workflows/test-build-release.yml

cp ~/Developer/.github/workflow-templates/deploy-${STACK}.yml \
   .github/workflows/deploy.yml
```

For Swift-only repos (no deploy yet):

```bash
cp ~/Developer/.github/workflow-templates/test-build-release-swift.yml \
   .github/workflows/test-build-release.yml
```

### Step 3: Configure

Edit `.github/workflows/test-build-release.yml`:
- Set `APP_TYPE` (static, python, node, go)
- Set `SITE_URL` (https://\<slug\>.bigbase.click)
- Adjust language-specific steps if needed

Edit `.github/workflows/deploy.yml`:
- Confirm `SITE_URL` matches
- Ensure repo secrets: `BIGBASE_SITE_ID`, `BIGBASE_DEPLOY_TOKEN` (BigBase stacks only)

Do **not** rename the workflow `name:` field — deploy listens for `"Test Build Release"`.

### Step 4: Remove old workflows

```bash
# Remove consolidated or legacy CI/CD
rm -f .github/workflows/ci-cd.yml .github/workflows/ci.yml .github/workflows/ci.yaml

# Remove old standalone deploy (if exists)
rm -f .github/workflows/deploy-bigbase.yml .github/workflows/deploy.yml.bak

# Keep CodeQL if desired
# rm .github/workflows/codeql.yml
```

### Step 5: Verify

```bash
yamllint .github/workflows/test-build-release.yml .github/workflows/deploy.yml
git add -A && git commit -m "refactor: split CI/CD into test-build-release + deploy pair"
git push -u origin refactor/split-ci-cd
```

### Step 6: Open PR

```bash
gh pr create --title "refactor: split CI/CD into test-build-release + deploy pair" --body "..."
```

## Naming convention

| File | YAML `name:` | Actions tab label |
|------|--------------|-------------------|
| `test-build-release.yml` | `Test Build Release` | Test Build Release |
| `deploy.yml` | `Deploy` or `Deploy Docs (...)` | Deploy |

Properties `name` in `.properties.json` is descriptive for the GitHub workflow picker (e.g. `Test Build Release (Node.js)`).

## Timeline

- [ ] 3.0.0 templates merged in `.github` repo
- [ ] Reference repo migrated (big-library or big-olive-books)
- [ ] Remaining portfolio repos migrated per stack table above
- [ ] Legacy `ci-cd-*.yml` templates removed from catalog
