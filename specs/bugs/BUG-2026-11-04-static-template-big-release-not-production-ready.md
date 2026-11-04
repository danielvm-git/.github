---
bug_id: BUG-2026-11-04-static-template-big-release-not-production-ready
status: open
severity: medium
scope: workflow-templates/test-build-release-static.yml
title: Make the big-release path in test-build-release-static production-ready (Issue #40)
---

# BUG-2026-11-04-static-template-big-release-not-production-ready: Make the big-release path in test-build-release-static production-ready

Security impact: NONE — no security exploit path identified.

## Problem

`workflow-templates/test-build-release-static.yml` (v4.1.1) and its reusable mirror `.github/workflows/test-build-release-static.yml` expose `release_tool: big-release`, but the `release` job and runtime defaults have 6 production gaps discovered while adopting it in `big-dock-locker-site` (Issue #40):

1. **Missing git identity for `big-release` (`git` plugin):** `big-release release --verbose` fails with `plugin "git" publish failed: failed to create tag: exit status 128: Committer identity unknown` because only `GITHUB_TOKEN` is set in `env`.
2. **Missing `VERSION` sync step:** Unlike the `bigbase-canary-*` reference workflows, there is no post-release step to read the newly created git tag, write `VERSION`, and commit/push `chore(release): update VERSION to $NEW_VER [skip ci]`.
3. **Node 22 hardcoded instead of Node 24 / configurable input:** Every job pins `node-version: 22` with no `node_version` input, whereas the portfolio standard for static/Node apps is Node 24.
4. **Stale action SHA pins:** `actions/checkout` is pinned to `v7.0.0` (`9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0`) instead of `v7.0.1` (`3d3c42e5aac5ba805825da76410c181273ba90b1`), and `actions/setup-node` is pinned to `v6.4.0` (`48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e`) instead of `v7.1.0` (`949feb2413d6458794dcd2491c4babbbce0c15c1`).
5. **`release_tool` default & standalone copy behavior:** `release_tool` defaults to `semantic-release`, and standalone copied workflows (`push` event where `inputs.release_tool` is empty) silently fall back to `semantic-release` unless edited.
6. **Undocumented `CHANGELOG.md` header contract:** `big-release`'s changelog plugin scans for the first `## ` header after line 0 (`# Changelog` + `## [Unreleased]` + `## [<version>]`). Repos with `# <version>` top-level headers silently no-op or drop entries, and the template does not document this contract.

## Root Cause Analysis

### 1. Reproduce
Inspecting `workflow-templates/test-build-release-static.yml` (v4.1.1) and running a consumer pipeline with `release_tool: big-release` reproduces the `exit status 128: Committer identity unknown` failure during `big-release release --verbose`, leaves `VERSION` un-updated after tagging, runs on Node 22 with `checkout@v7.0.0` and `setup-node@v6.4.0`, and defaults to `semantic-release`.

### 2. Isolate
The issue is isolated to the static CI/CD workflow template pair (`workflow-templates/test-build-release-static.yml` and `.github/workflows/test-build-release-static.yml`) and template validation in `scripts/validate-templates.sh`. Comparing against `bigbase-canary-node/.github/workflows/test-build-release.yml` confirms that the canary workflow added `GIT_AUTHOR_*` / `GIT_COMMITTER_*` environment variables and the `Update VERSION file` step locally without backporting them to the central static template.

### 3. Hypothesize
- **H1:** When `v4.1.0` introduced `release_tool: big-release` into the template catalog, only the binary download + `big-release release --verbose` command was added, omitting the git committer identity environment variables and the post-release `VERSION` file sync step that `bigbase-canary-*` required in practice.
- **H2:** Action pins (`checkout@v7.0.0`, `setup-node@v6.4.0`) and `node-version: 22` were frozen at v3.0.1 and never updated to Node 24 / `checkout@v7.0.1` / `setup-node@v7.1.0`.

### 4. Verify
Verified directly against `workflow-templates/test-build-release-static.yml` lines 6–168 and `bigbase-canary-node/.github/workflows/test-build-release.yml` lines 135–165:
- H1 and H2 are both confirmed. `Run big-release` only passes `GITHUB_TOKEN`, lacks `GIT_AUTHOR_*`/`GIT_COMMITTER_*`, has no `Update VERSION file` step, hardcodes `node-version: 22`, pins `checkout@v7.0.0` and `setup-node@v6.4.0`, defaults `release_tool` to `semantic-release`, and lacks `CHANGELOG.md` header contract documentation.
- Risk level: Low (scoped to static workflow template pair, validation script, and changelog).

## TDD Fix Plan

1. **RED**: Add a static template production-readiness check in `scripts/validate-templates.sh` asserting that `test-build-release-static.yml` (and its `.github/workflows/` mirror) defines `node_version` defaulting to `24`, defaults `release_tool` to `big-release`, pins `actions/checkout` to `v7.0.1` (`3d3c42e5aac5ba805825da76410c181273ba90b1`) and `actions/setup-node` to `v7.1.0` (`949feb2413d6458794dcd2491c4babbbce0c15c1`), sets `GIT_AUTHOR_NAME`/`GIT_COMMITTER_NAME` for `big-release`, includes the `Update VERSION file` step, documents the `CHANGELOG.md` `## ` header contract, and is bumped to version `4.2.0`.
   **GREEN**: Update `workflow-templates/test-build-release-static.yml`, `.github/workflows/test-build-release-static.yml`, and `workflow-templates/CHANGELOG.md` to satisfy all checks.
   **verify**: `bash scripts/validate-templates.sh && bash scripts/preflight.sh`

## Acceptance Criteria

- [ ] `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`, `GIT_COMMITTER_NAME`, `GIT_COMMITTER_EMAIL` configured on `Run big-release`
- [ ] `Update VERSION file` step added after `Run big-release` (guarded by `big-release` release_tool condition)
- [ ] `node_version` input added (default `"24"`) and used across `test`, `build`, and `release` jobs
- [ ] `release_tool` defaults to `"big-release"` (both `workflow_call` input default and standalone fallback)
- [ ] Action pins refreshed to `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1` and `actions/setup-node@949feb2413d6458794dcd2491c4babbbce0c15c1 # v7.1.0`
- [ ] `CHANGELOG.md` header contract (`# Changelog` + `## [Unreleased]` + `## [version]`) documented in the template
- [ ] Template version bumped to `4.2.0` in both `workflow-templates/test-build-release-static.yml` and `.github/workflows/test-build-release-static.yml`, with `workflow-templates/CHANGELOG.md` entry added
- [ ] `bash scripts/validate-templates.sh` and `bash scripts/preflight.sh` pass

## Resolution

<!-- filled in by validate-fix -->
