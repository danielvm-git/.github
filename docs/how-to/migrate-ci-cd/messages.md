---
type: How-to
title: CI/CD Migration Messages — Per-Repo Walkthroughs
description: Pre-written migration messages and step-by-step walkthroughs for each danielvm-git repo.
tags: [ci-cd, migration, templates, walkthrough]
timestamp: 2026-07-13
provenance: docs/how-to/migrate-ci-cd/messages.md
---

# CI/CD Migration Messages — Per-Repo Walkthroughs

> Ready to send to each repo's developers. Validate before posting.

---

## 1. bigbase

**Repo:** `danielvm-git/bigbase`
**Current:** ci.yml, codeql.yml, pr-review.yaml, release-deploy.yml
**Target:** `ci-cd-go.yml`

Hey! The `.github` template repo just got a major redesign — 16 separate workflow templates consolidated into 9 unified pipelines. Every template now follows a 4-stage pattern: `ci → verify → semantic-release → deploy`.

For `bigbase`, I recommend migrating to `ci-cd-go.yml`.

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

# Remove old CI workflow
rm .github/workflows/ci.yml

yamllint .github/workflows/ci-cd.yml
git add -A && git commit -m "refactor: consolidate CI/CD into single pipeline"
git push -u origin refactor/consolidate-ci-cd
gh pr create
```

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 2. bigpowers

**Repo:** `danielvm-git/bigpowers`
**Current:** agent-locks.yml, agentics-maintenance.yml, docs-site.yml, publish.yml, sync-*.yml
**Target:** `ci-cd-node.yml` + `ci-cd-pages-starlight.yml`

For `bigpowers`, the agent workflows (agent-locks, agentics-maintenance, sync-*, publish-wiki) should stay as-is. But the docs site can be migrated.

### What changes

| Old | New |
|-----|-----|
| `docs-site.yml` | `ci-cd-pages-starlight.yml` |
| Agent workflows | Keep as-is |

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 3. grimoire

**Repo:** `danielvm-git/grimoire`
**Current:** ci.yml, codeql.yml, deploy.yml, docs.yaml
**Target:** `ci-cd-python.yml` + `ci-cd-pages-mkdocs.yml`

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 4. big-bolao

**Repo:** `danielvm-git/big-bolao`
**Current:** ci-cd.yml, codeql-javascript.yml, codeql-python.yml
**Target:** `ci-cd-monorepo.yml` or `ci-cd-node.yml`

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 5. big-counter

**Repo:** `danielvm-git/big-counter`
**Current:** ci.yaml, codeql.yml, release.yaml
**Target:** `ci-cd-python.yml`

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 6. astrobiologia

**Repo:** `danielvm-git/astrobiologia`
**Current:** ci.yml, deploy-bigbase.yml
**Target:** `ci-cd-static.yml`

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 7. big-library

**Repo:** `danielvm-git/big-library`
**Current:** ci-cd.yml, codeql.yml
**Target:** `ci-cd-monorepo.yml`

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 8. big-olive-books

**Repo:** `danielvm-git/big-olive-books`
**Current:** ci-cd.yml
**Target:** `ci-cd-static.yml`

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 9. big-token-saver

**Repo:** `danielvm-git/big-token-saver`
**Current:** ci.yml, release.yml
**Target:** `ci-cd-monorepo.yml`

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`

---

## 10. big-quiqui

**Repo:** `danielvm-git/big-quiqui`
**Current:** lint_and_test.yml, release.yml
**Target:** `ci-cd-node.yml`

Full migration plan: `docs/how-to/migrate-ci-cd/migration-plan.md`
