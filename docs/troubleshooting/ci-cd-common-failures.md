---
type: Troubleshooting
title: CI/CD Common Failures
description: Diagnose and fix common GitHub Actions CI/CD misconfigurations in the danielvm-git portfolio — broad permissions, missing timeouts, missing concurrency, and unpinned runners.
tags: [ci-cd, github-actions, troubleshooting, workflow, portfolio]
timestamp: 2026-07-13
provenance: docs/reference/audit-history.md (2026-07 audit findings)
story: e01s04
---

# CI/CD Common Failures

## Overview

The 2026-07 portfolio audit scanned 54 workflow files across 22 repos. Four patterns accounted for the majority of findings. Each section below follows the same format — symptom, cause, fix — so you can diagnose quickly and apply the correction.

---

## Broad permissions

### Symptom

The workflow runs but grants every permission by default — or explicitly sets `permissions: write-all`. GitHub's Dependabot alerts flag the workflow as overly permissive.

### Cause

Workflow files without an explicit `permissions:` block inherit GitHub's default, which grants write access to most scopes. Some templates omitted the block entirely because they were authored before GitHub strengthened the default. In the audit, 28 of 54 files (52 %) had no `permissions:` block.

### Fix

Add a least-privilege `permissions:` block at the top of every workflow:

```yaml
permissions:
  contents: read
  issues: write   # only if the workflow creates issues
  pull-requests: write   # only if the workflow comments on PRs
```

When a job needs elevated rights (e.g., pushing a release), scope the permission to that job alone:

```yaml
jobs:
  release:
    permissions:
      contents: write
    steps:
      - run: make release
```

---

## No timeout

### Symptom

A workflow runs indefinitely — stuck for hours on a hung step — blocking the runner and delaying other jobs.

### Cause

No `timeout-minutes` set at the job level. By default, GitHub Actions allows each job 360 minutes (6 hours). A hung `apt-get install`, a stuck `npm install` behind a proxy, or an infinite loop in a test suite can consume the full allocation. The audit found 45 of 54 files (83 %) missing a timeout.

### Fix

Add `timeout-minutes` to every job. The portfolio standard is 10 minutes for lint/test jobs and 15 minutes for deploy jobs:

```yaml
jobs:
  test:
    timeout-minutes: 10
    steps:
      - run: make test

  deploy:
    timeout-minutes: 15
    steps:
      - run: make deploy
```

---

## No concurrency

### Symptom

Pushing two commits in quick succession starts two workflow runs that race against each other. The older run may deploy after the newer one, causing a version rollback.

### Cause

The workflow has no `concurrency` group. GitHub Actions does not cancel in-flight runs by default. The audit found most portfolio workflows lacked a concurrency group.

### Fix

Add a `concurrency` block at the workflow level, keyed to the branch, and set `cancel-in-progress: true` for CI jobs:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

For deploy workflows, keep `cancel-in-progress: false` to avoid interrupting a deployment:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: false
```

---

## Unpinned runners

### Symptom

A workflow that passed last week fails today with a cryptic error — a tool version changed, a package was removed, or the default OS image was updated.

### Cause

The workflow uses `ubuntu-latest` without pinning to a specific image version. GitHub updates the `latest` tag on major image releases, which can break workflows that depend on specific tool versions.

### Fix

Pin to a specific runner version. For Ubuntu, use `ubuntu-24.04` or `ubuntu-22.04` instead of `ubuntu-latest`:

```yaml
jobs:
  test:
    runs-on: ubuntu-24.04
```

For macOS or Windows, use the corresponding versioned label. Review and bump the pinned version quarterly during regular maintenance.
