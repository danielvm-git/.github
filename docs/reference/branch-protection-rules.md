---
type: reference
title: Branch protection baseline
---

# Branch protection rules

Every danielvm-git repo must configure these settings on `main` (and `master` if present).

## Required settings

| Rule | Value | Rationale |
|------|-------|-----------|
| Require a pull request before merging | ✅ On | P1 no-direct-work-on-main |
| Require approvals | 1 | Solo dev — self-approval via `gh pr create` |
| Dismiss stale approvals on new commits | ✅ On | Old approval ≠ current diff |
| Require status checks to pass | ✅ On | CI must be green |
| Require branches to be up to date | ✅ Off | Solo dev — no contention |
| Require conversation resolution | ✅ On | All threads resolved before merge |
| Require signed commits | ✅ Off | Optional (bigpowers disables AI co-authors) |
| Require linear history | ✅ Off | Squash-merge is cleaner |
| Allow force pushes | 🔴 Off | P0 — never |
| Allow deletions | 🔴 Off | P0 — never |
| Require deployments to succeed | ✅ On (if deploy workflow exists) | |

## How to set up (GitHub UI)

1. Repo → Settings → Branches → Add branch protection rule
2. Branch name pattern: `main`
3. Check the boxes above
4. Create

## How to set up (bulk via gh CLI)

```bash
# Apply to a single repo
gh api repos/danielvm-git/REPO/branches/main/protection \
  --method PUT \
  --input branch-protection.json

# Audit all repos
bash scripts/audit-branch-protection.sh
```

## Exceptions

Repos without CI (template-only repos like this one) may skip "Require status checks" — document the exception in `specs/state.yaml`.
