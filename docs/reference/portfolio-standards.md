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

Select the template matching your project's primary stack. Templates are maintained in `workflow-templates/` and inherited via the `.github` template layer.

| Project type | Template | Features |
|-------------|----------|----------|
| Node.js / TypeScript monorepo | `ci-cd-monorepo.yml` | Lint, typecheck, test, build, deploy |
| Python application | `ci-cd-python.yml` | Lint, test, build, deploy |
| Swift application | `ci-cd-swift.yml` | Lint, test, build, deploy |
| Rust application | `ci-cd-rust.yml` | Lint, test, build, deploy |
| JavaScript library | `ci-js.yml` | Lint, test, publish |
| JavaScript static site | `ci-cd-pages-js.yml` | Lint, build, deploy to GitHub Pages |
| Python static site | `ci-cd-pages-python.yml` | Lint, build, deploy to GitHub Pages |
| Swift static site | `ci-cd-pages-swift.yml` | Lint, build, deploy to GitHub Pages |
| Code quality (all repos) | `codeql-javascript.yml` | CodeQL analysis (added via security tab) |

All templates include:
- `concurrency` group to cancel stale runs
- `timeout-minutes: 10` to prevent runaway jobs
- Pinned runner versions (`actions/checkout@v4`, etc.)

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
| Workflow files | kebab-case | `ci-cd-monorepo.yml` |
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
