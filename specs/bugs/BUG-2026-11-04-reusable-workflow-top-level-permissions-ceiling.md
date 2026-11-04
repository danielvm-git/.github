---
bug_id: BUG-2026-11-04-reusable-workflow-top-level-permissions-ceiling
status: open
severity: high
scope: workflow-templates/test-build-release-*.yml
title: Reusable workflow top-level permissions block prevents release job from escalating (Issue #34)
---

# BUG-2026-11-04-reusable-workflow-top-level-permissions-ceiling: Reusable workflow top-level permissions block prevents release job from escalating

Security impact: LOW — least-privilege is preserved by scoping `permissions: contents: read` at the job level (`test`, `build`, `lint`, `verify`) instead of workflow root. No security exploit path identified.

## Problem

The reusable workflows in `.github/workflows/test-build-release-*.yml` and `workflow-templates/test-build-release-*.yml` declare a top-level `permissions: contents: read` block while the `release` job declares `permissions: contents: write, issues: write, pull-requests: write`. In GitHub Actions reusable workflows (`on: workflow_call`), a top-level `permissions` block acts as a ceiling that prevents job-level permissions from escalating beyond `contents: read`, causing `startup_failure` or `GITHUB_TOKEN` permission failure during `release`.

## Root Cause Analysis

### 1. Reproduce
Calling `.github/workflows/test-build-release-python.yml@main` (or any of the 8 release-capable `test-build-release-*.yml` reusable workflows) from a caller workflow that grants `contents: write` fails at startup or release time because the called workflow's root `permissions: contents: read` restricts the token ceiling.

### 2. Isolate
Isolated to the root `permissions: contents: read` block in `test-build-release-{fullstack,go,monorepo,node,php,python,static,swift}.yml` (and `pages-mkdocs`, `pages-starlight`) across `workflow-templates/` and `.github/workflows/`.

### 3. Hypothesize
- **H1:** When `v4.0.0` converted standalone templates to `workflow_call` reusable workflows, the root `permissions: contents: read` block was kept at the workflow top level instead of being scoped per non-release job (`test`, `build`, `lint`, `verify`).

### 4. Verify
Confirmed across all 10 `test-build-release-*.yml` files: every file has `^permissions:\n  contents: read` at the root, while `jobs.test`, `jobs.build`, `jobs.lint`, and `jobs.verify` omit job-level `permissions:` and `jobs.release` specifies `contents: write`. Moving `permissions: contents: read` from the workflow root to each non-release job preserves least-privilege on every job while allowing `jobs.release` to use the caller's write permissions.

## TDD Fix Plan

1. **RED**: Add a check in `scripts/validate-templates.sh` asserting that no `test-build-release-*.yml` template or `.github/workflows/test-build-release-*.yml` mirror declares top-level `^permissions:` (all permissions must be scoped per job so `release` can escalate under `workflow_call`).
   **GREEN**: Move `permissions: contents: read` from the workflow root to each non-release job (`test`, `build`, `lint`, `verify`, and `release` in docs-only `pages-*` templates) across `workflow-templates/test-build-release-*.yml` and `.github/workflows/test-build-release-*.yml`, update `specs/big-release-option-b-gap-register.md` and `workflow-templates/CHANGELOG.md`.
   **verify**: `bash scripts/validate-templates.sh && bash scripts/preflight.sh`

## Acceptance Criteria

- [ ] No `test-build-release-*.yml` in `workflow-templates/` or `.github/workflows/` has a top-level `^permissions:` ceiling
- [ ] Every non-release job (`test`, `build`, `lint`, `verify`, and docs-only `release`) explicitly sets job-level `permissions: contents: read`
- [ ] Every release job in the 8 release-capable templates retains `permissions: contents: write, issues: write, pull-requests: write`
- [ ] `bash scripts/validate-templates.sh` and `bash scripts/preflight.sh` pass

## Resolution

<!-- filled in by validate-fix -->
