---
type: Reference
title: CI/CD Migration Plan — Consolidated Templates
description: Migration plan for moving portfolio repos from 16 separate workflow templates to 9 unified CI/CD pipelines.
tags: [ci-cd, migration, templates, planning]
timestamp: 2026-07-13
provenance: docs/how-to/migrate-ci-cd/migration-plan.md
---

# CI/CD Migration Plan — Consolidated Templates

> **Date:** 2026-07-11
> **PR:** https://github.com/danielvm-git/.github/pull/11
> **Status:** Ready for per-repo migration

## Overview

The `.github` template repo has been redesigned from 16 separate workflow templates to 9 unified CI/CD pipelines. Every `ci-cd-*.yml` template now follows a 4-stage pipeline pattern:

```text
ci → verify → semantic-release → deploy
```

- **ci**: Language-specific lint, typecheck, test, build + artifact upload
- **verify**: Preflight + conventional commits + no AI attribution
- **semantic-release**: Version bump, changelog, GitHub release (main branch only)
- **deploy**: Conditional BigBase deploy via `bigbase-deploy` action

## Migration scope

### Repos to migrate (10)

| # | Repo | Stack | Current Workflows | New Template |
|---|------|-------|-------------------|--------------|
| 1 | `bigbase` | Go + Node.js | ci.yml, codeql.yml, pr-review.yaml, release-deploy.yml | `ci-cd-go.yml` |
| 2 | `bigpowers` | Node.js + Python + docs | agent-locks.yml, agentics-maintenance.yml, docs-site.yml, publish.yml, sync-*.yml | `ci-cd-node.yml` + `ci-cd-pages-starlight.yml` |
| 3 | `grimoire` | Python + docs | ci.yml, codeql.yml, deploy.yml, docs.yaml | `ci-cd-python.yml` + `ci-cd-pages-mkdocs.yml` |
| 4 | `big-bolao` | Node.js + Python | ci-cd.yml, codeql-javascript.yml, codeql-python.yml | `ci-cd-node.yml` or `ci-cd-monorepo.yml` |
| 5 | `big-counter` | Python | ci.yaml, codeql.yml, release.yaml | `ci-cd-python.yml` |
| 6 | `astrobiologia` | Node.js + docs | ci.yml, deploy-bigbase.yml | `ci-cd-static.yml` |
| 7 | `big-library` | Node.js + Python | ci-cd.yml, codeql.yml | `ci-cd-monorepo.yml` |
| 8 | `big-olive-books` | Node.js | ci-cd.yml | `ci-cd-static.yml` |
| 9 | `big-token-saver` | Node.js + Rust | ci.yml, release.yml | `ci-cd-monorepo.yml` |
| 10 | `big-quiqui` | Node.js | lint_and_test.yml, release.yml | `ci-cd-node.yml` |

## Template selection guide

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
