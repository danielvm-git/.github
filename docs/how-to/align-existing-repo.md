---
type: How-to
title: Align an Existing Repo to the Portfolio Standard
description: Step-by-step guide for migrating an existing danielvm-git repo to the .github portfolio standard.
tags: [migration, portfolio, standards, ci-cd, agents]
timestamp: 2026-07-13
provenance: docs/how-to/align-existing-repo.md
---

# Align an Existing Repo to the Portfolio Standard

## Overview

This guide walks repo maintainers through the process of migrating an existing `danielvm-git/*` project to the portfolio standard defined in this `.github` reference repo. Each section is a discrete step with verification commands.

## Before you start

- Repo cloned locally under `~/Developer/`
- BigBase deploy token provisioned if the project deploys
- `yamllint` installed for workflow validation

## Checklist

### 1. Agent context files

```bash
# If CLAUDE.md and GEMINI.md are regular files (not symlinks):
rm CLAUDE.md GEMINI.md
ln -s AGENTS.md CLAUDE.md
ln -s AGENTS.md GEMINI.md

# Verify:
test -L CLAUDE.md && echo "✅ CLAUDE.md is symlink"
test -L GEMINI.md && echo "✅ GEMINI.md is symlink"
```

### 2. README

- [ ] Build Status badge links to the Actions tab
- [ ] Commands table matches actual scripts
- [ ] Preflight row lists the full-green command
- [ ] Tech Stack table is correct
- [ ] Contribute section points to `CONTRIBUTING.md` or Conventional Commits

### 3. CI/CD workflow

- [ ] Workflow lives at `.github/workflows/ci-cd-<language>.yml` (copy from `workflow-templates/`)
- [ ] Template matches project stack
- [ ] Actions pinned per security best practices
- [ ] `permissions: contents: read` at workflow level
- [ ] `timeout-minutes` set on every job
- [ ] `concurrency` group set at workflow level
- [ ] `runs-on: ubuntu-22.04` (not `-latest`)

### 4. Deploy auth — BigBase projects only

- [ ] Deploy uses `BIGBASE_DEPLOY_TOKEN` (scoped), never `BIGBASE_EMAIL`/`BIGBASE_PASSWORD`
- [ ] Deploy step uses `danielvm-git/.github/actions/bigbase-deploy@main`
- [ ] `BIGBASE_SITE_ID` secret is set in repo settings
- [ ] Health check verifies the site is live after deploy

### 5. CONVENTIONS.md

- [ ] If the repo has `CONVENTIONS.md`, verify it's accurate
- [ ] "Always Green" / fix-or-log doctrine is documented

### 6. Preflight

```bash
npm test && npm run lint && npm run build   # Node/Vue
pytest && ruff check . && mypy src/         # Python
swift test && swift build                   # Swift
```

### 7. Brand tokens

```bash
~/Developer/.github/scripts/pull-brand-tokens.sh .
```

### 8. Verify

```bash
~/Developer/.github/scripts/audit-workflows.sh --repo $(basename $(pwd))
```

## Common issues

| Symptom | Fix |
|---------|-----|
| `bigbase-deploy` action fails with "token not set" | Provision `BIGBASE_DEPLOY_TOKEN` in repo secrets |
| ESLint 9 flat config error | Create `eslint.config.js` with `@vue/eslint-config-typescript` |
| `ruff` catches violations that `black`+`isort` ignored | Run `ruff check --fix` once, commit separately |
| `concurrency` group name conflicts | Use `ci-${{ github.workflow }}-${{ github.ref }}` pattern |

## See also

- [Git Safety Hooks](guard-git-safety-hooks.md) — Block dangerous git operations
- [Agent Context Files](agent-context-files.md) — CLAUDE.md/AGENTS.md setup
- [Branch Protection Rules](../reference/branch-protection-rules.md)
