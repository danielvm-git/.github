---
type: Release Notes
title: 2026-07 Release Notes — Template Consolidation, Docs Refactor, and Audit Findings
description: July 2026 release covering the template consolidation, bigbase-deploy action, docs refactor to Good Docs + OKF, and audit-driven hardening.
tags: [release-notes, 2026-07, templates, docs, audit, bigbase-deploy]
timestamp: 2026-07-13
story: e01s04
---

# 2026-07 Release Notes

**Version:** 2026-07
**Release date:** 2026-07-13
**Status:** Released

---

## Template Consolidation

- Consolidated 54 workflow files across 22 repos into a shared template layer.
- Every workflow now references templates from `.github/workflow-templates/` instead of maintaining per-repo copies.
- Added `permissions:` blocks, `timeout-minutes`, and `concurrency` groups to all templates.
- New templates: `ci-cd-monorepo.yml`, `ci-cd-swift.yml`, `ci-javascript.yml`, `ci-swift.yml`, `deploy-vps.yml`.

## bigbase-deploy Action

- New reusable action at `actions/bigbase-deploy/` — the single deploy step that every project calls.
- Supports `static`, `node`, `go`, and `docker` app types.
- Built-in health check with configurable timeout and URL.
- Requires `DEPLOY_TOKEN` secret for VPS authentication.

## Docs Refactor

- Migrated all documentation from a loose collection to Good Docs Project templates with OKF frontmatter.
- New folder structure: `concept/`, `how-to/`, `tutorial/`, `reference/`, `api-reference/`, `troubleshooting/`, `release-notes/`, `style-guide/`, `glossary/`.
- New content:
  - **How-to:** Start a new project, install git safety hooks, use GitHub quickstart.
  - **Reference:** Portfolio standards, branch protection rules, CI/CD templates reference, audit history.
  - **Concept:** Portfolio architecture, bigpowers methodology overview.
  - **Troubleshooting:** CI/CD common failures, deploy health check failures.
  - **Glossary:** Domain terms glossary.
  - **Style Guide:** Portfolio writing standards.
- Renamed `explanation/` → `concept/` (Good Docs taxonomy).
- Renamed files for Akita naming compliance (`bigpowers-learnings` → `bigpowers-methodology-overview`, `new-project-quickstart` → `github-quickstart`).
- Consolidated `audit-history/` into a single `reference/audit-history.md`.
- Added OKF `index.md` bundle root with section links.

## Audit Findings

- Full portfolio audit completed 2026-07: 54 workflows across 22 repos.
- **52%** missing `permissions:` block — resolved in template consolidation.
- **83%** missing `timeout-minutes` — added to all templates.
- **~50%** missing `concurrency` groups — added to all applicable templates.
- Unpinned runner labels (`ubuntu-latest`) replaced with versioned labels (`ubuntu-24.04`).
- Findings documented in `docs/reference/audit-history.md` and `docs/troubleshooting/`.

## Upcoming

- **e01s03:** Knowledge hub entry points — start-new-project, portfolio-standards, portfolio-architecture.
- **e01s05:** Auto-generation and validation tooling (doc indexes, doc validation scripts).
- Continued hardening of remaining per-repo workflow files.
