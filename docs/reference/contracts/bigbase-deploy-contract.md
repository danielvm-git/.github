---
type: reference
title: bigbase-deploy contract
---

# bigbase-deploy contract

## Required repo secrets

| Secret | Notes |
|---|---|
| `BIGBASE_DEPLOY_TOKEN` | Scoped to one site. Provision via `bigbase_provision_ci_credentials`. Never use account email/password. |
| `BIGBASE_SITE_ID` | The site this token is scoped to. |

## SHA-pinned deploy

Deploy is SHA-pinned via the action `ref` input (commit SHA or tag). Prefer passing the exact SHA/tag from the `deploy-meta` artifact produced by `test-build-release`. When `ref` is empty, the action falls back to `branch` for migration back-compat.

POST payload includes both `ref` and `branch` (branch retained for API back-compat).

### BigBase API dependency

The BigBase deploy API **must honor `ref`** for SHA/tag pinning and rollback to work. If the API currently ignores `ref` and always deploys HEAD of `branch`, that is a **hard dependency** on the `bigbase` app — track and fix there. This contract and action still ship the `ref` field so consumers can pin once the API honors it.

## Rollback

Rollback = re-deploy a prior known-good tag or commit SHA:

1. Re-run the Deploy workflow with `ref` set to the prior tag/SHA (or `gh workflow run` / equivalent with the same inputs).
2. Health check remains a separate step after the deploy POST; a failed health check fails the job — no silent leave-broken beyond that failure.

There is no separate rollback API; prior tag/SHA re-deploy is the rollback path.

## Token rotation (`BIGBASE_DEPLOY_TOKEN`)

OIDC is N/A for BigBase (custom API auth). Rotate `BIGBASE_DEPLOY_TOKEN` when:

- A token may have been exposed (logs, fork PR, leaked secret)
- Site ownership or operator access changes
- Periodic hygiene (recommend at least annually, or after any CI credential audit)

Rotation: revoke the old token in BigBase, provision a new scoped token via `bigbase_provision_ci_credentials`, update the repo secret `BIGBASE_DEPLOY_TOKEN`, confirm a successful deploy.

## `app_type` values in use

| Value | Used by |
|---|---|
| `static` | Astro/Vue/plain static builds |
| `python` | big-bolao |
| `go` | big-library (MCP server) |
| `node` | not yet exercised live — confirm behavior before relying on it |

## Health check contract

8 attempts, 10s interval, accepts HTTP 200/301/302 as healthy. Runs as its own distinct step after the deploy POST. Failing after 8 attempts fails the job — no silent partial-deploy state.

## Migration status

All known repos migrated to scoped `BIGBASE_DEPLOY_TOKEN` as of 2026-07-10:
- `big-bolao` — migrated (commit b63fa5b)
- `big-library` — migrated (commit 0a43f24)
- `big-olive-books` — migrated (eslint.config.js + ci-cd.yml token auth)

No repos remain on `BIGBASE_EMAIL`/`BIGBASE_PASSWORD` auth. See `docs/reference/audit-history/2026-07-audit.md` for the original audit finding.
