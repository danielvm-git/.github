---
type: Reference
title: Portfolio Standards
description: Consolidated reference for all danielvm-git portfolio-wide standards — agent context, branch protection, CI/CD, deploy, naming conventions, and git safety.
tags: [standards, reference, ci-cd, branch-protection, naming, git-safety]
timestamp: 2026-07-13
---

# Portfolio Standards

## Overview

This document consolidates every standard that applies across all 28 danielvm-git portfolio repos. Each section links to the full canonical doc for details.

## Agent context files

Every repo maintains a single canonical `AGENTS.md` with symlinks for multi-agent tools. This prevents silent drift between `CLAUDE.md`, `GEMINI.md`, and `AGENTS.md`.

**Rule**: `CLAUDE.md` and `GEMINI.md` must be symlinks to `AGENTS.md`, not independent files.

```bash
# Verify
ls -la CLAUDE.md GEMINI.md
# Good: CLAUDE.md -> AGENTS.md, GEMINI.md -> AGENTS.md
# Bad: independent files with different sizes
```

See [Agent Context Files](agent-context-files.md) for the full pattern, setup, repair, and multi-agent tool table.

## Branch protection

Every repo must configure branch protection on `main` (and `master` if present).

| Rule | Setting |
|------|---------|
| Require PR before merging | On |
| Required approvals | 1 |
| Dismiss stale approvals | On |
| Require status checks | On |
| Require conversation resolution | On |
| Require signed commits | Off |
| Require up-to-date branches | Off (solo dev) |
| Include administrators | On |

See [Branch Protection Rules](branch-protection-rules.md) for the full baseline with justifications.

## CI/CD templates

Every repo copies one pair from `workflow-templates/` into `.github/workflows/`: `test-build-release-<stack>.yml` becomes `test-build-release.yml` (runs on push and pull request), and `deploy-<stack>.yml` becomes `deploy.yml` (runs on `workflow_run` of `Test Build Release`, job gated on `conclusion == 'success'` and `head_branch == 'main'`). A thin `ci-cd.yml` that calls reusable workflows is not the pattern.

| Stack | Pipeline template | Deploy template |
|-------|-------------------|-----------------|
| Node.js / TypeScript | `test-build-release-node.yml` | `deploy-node.yml` |
| Python | `test-build-release-python.yml` | `deploy-python.yml` |
| Go | `test-build-release-go.yml` | `deploy-go.yml` |
| Static site | `test-build-release-static.yml` | `deploy-static.yml` |
| PHP | `test-build-release-php.yml` | `deploy-php.yml` |
| Monorepo | `test-build-release-monorepo.yml` | `deploy-monorepo.yml` |
| Fullstack | `test-build-release-fullstack.yml` | `deploy-fullstack.yml` |
| Swift | `test-build-release-swift.yml` | *(no deploy)* |
| Godot | `test-build-release-godot.yml` | *(no deploy)* |
| MkDocs docs site | `test-build-release-pages-mkdocs.yml` | `deploy-pages-mkdocs.yml` |
| Starlight docs site | `test-build-release-pages-starlight.yml` | `deploy-pages-starlight.yml` |
| Code scanning (all repos) | `codeql.yml` or `codeql-javascript.yml` | — |

All templates set a `concurrency` group (`cancel-in-progress: true` on the pipeline, `false` on deploy), `timeout-minutes` on every job, `runs-on: ubuntu-22.04` (Swift uses macOS), and pin every action to a full 40-character commit SHA.

See [Start a New Project](../how-to/start-new-project.md) for step-by-step CI wiring.

## Deploy contract

The `bigbase-deploy` action is the single deploy step every project calls. It requires:

| Item | Details |
|------|---------|
| Action | `danielvm-git/.github/actions/bigbase-deploy@v1` |
| Secret `BIGBASE_DEPLOY_TOKEN` | Scoped per-site, provisioned via `bigbase_provision_ci_credentials` |
| Secret `BIGBASE_SITE_ID` | The site this token is scoped to |
| Input `app_type` | One of: `node`, `python`, `swift`, `static`, `docker` |
| Health check | Action waits for HTTP 200 on the deploy URL after deploy |

See [BigBase Deploy Contract](contracts/bigbase-deploy-contract.md) for the full specification.

## Naming conventions

| Layer | Convention | Example |
|-------|-----------|---------|
| Repos | kebab-case | `my-awesome-service` |
| Branches | `type/slug` | `feat/add-auth`, `fix/null-pointer` |
| Commits | Conventional Commits | `feat: add login endpoint` |
| Doc filenames | kebab-case, Akita-grep-unique | `guard-git-safety-hooks.md` (not `git-safety-hooks.md`) |
| Workflow files | kebab-case | `test-build-release.yml` |
| Action names | kebab-case | `bigbase-deploy` |
| Secrets | UPPER_SNAKE_CASE | `BIGBASE_DEPLOY_TOKEN` |
| Environment variables | UPPER_SNAKE_CASE | `NODE_ENV=production` |

### Akita naming rule

Doc filenames must return fewer than 5 grep results when searched across all portolio repos. If a `grep -r '<name>' /Users/danielvm/Developer/` returns 5+, rename the file to something more specific.

## Git safety

AI agents are blocked from destructive git operations via `guard-git` pre-tool-use hooks.

| Operation | Blocked? |
|-----------|----------|
| `git push origin main` | Blocked |
| `git push origin feature-branch` | Allowed |
| `git push --force` | Blocked |
| `git reset --hard` | Blocked |
| `git branch -D main` | Blocked |
| Non-Conventional Commit messages | Blocked |
| `Co-authored-by:` in commit message | Blocked (P1) |

Emergency bypass: set `GIT_BIGPOWERS_LAND=1` (used by `scripts/land-branch.sh`).

See [Guard Git Safety Hooks](../how-to/guard-git-safety-hooks.md) for installation, verification, and emergency bypass.
