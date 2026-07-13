---
type: Reference
title: Branch Protection Baseline
description: Required branch protection settings for every danielvm-git repo with justification for each rule.
tags: [branch-protection, security, github, settings]
timestamp: 2026-07-13
---

# Branch Protection Rules

## Overview

Every danielvm-git repo must configure these settings on `main` (and `master` if present). These rules enforce the no-direct-work-on-main policy and ensure CI gating.

## Required settings

| Rule | Value | Rationale |
|------|-------|-----------|
| Require a pull request before merging | ✅ On | P1 no-direct-work-on-main |
| Require approvals | 1 | Solo dev — self-approval via PR |
| Dismiss stale approvals on new commits | ✅ On | Old approval ≠ current diff |
| Require status checks to pass | ✅ On | CI must be green |
| Require branches to be up to date | ✅ Off | Solo dev — no contention |
| Require conversation resolution | ✅ On | All threads resolved before merge |
| Require signed commits | ✅ Off | Optional (bigpowers disables AI co-authors) |
| Require linear history | ✅ Off | Squash-merge is cleaner |
| Allow force pushes | 🔴 Off | P0 — never |
| Allow deletions | 🔴 Off | P0 — never |
| Require deployments to succeed | ✅ On (if deploy exists) | |

## Setup (GitHub UI)

1. Repo → Settings → Branches → Add branch protection rule
2. Branch name pattern: `main`
3. Check the boxes above
4. Create

## Setup (bulk via gh CLI)

```bash
gh api repos/danielvm-git/REPO/branches/main/protection \
  --method PUT \
  --input branch-protection.json
```

## Exceptions

Repos without CI (template-only repos) may skip "Require status checks" — document the exception in `specs/state.yaml`.
