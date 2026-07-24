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

## Deploy request

The action POSTs to `POST /api/sites/{site_id}/deploy` with JSON:

| Field | Source | Notes |
|---|---|---|
| `branch` | `inputs.branch` | Kept for API back-compat (default `main`) |
| `ref` | `inputs.ref`, or `inputs.branch` if `ref` empty | **Pinned commit SHA or tag** — what CI tested |
| `app_type` | `inputs.app_type` | `static`, `python`, `node`, or `go` |
| `passthrough_paths` | `inputs.passthrough_paths` | JSON array of URL paths |

**BigBase API dependency:** the server must honor `ref` and deploy that revision, not floating branch HEAD. If the API ignores `ref` today, treat that as a blocker in the `bigbase` app repo — the template contract and action still send it.

## `app_type` values in use

| Value | Used by |
|---|---|
| `static` | Astro/Vue/plain static builds |
| `python` | big-bolao |
| `go` | big-library (MCP server) |
| `node` | not yet exercised live — confirm behavior before relying on it |

## Health check contract

8 attempts, 10s interval, accepts HTTP 200/301/302 as healthy. Failing after 8 attempts fails the job — no silent partial-deploy state. Health check is a **separate step** after the deploy POST.

## Rollback

Redeploy a known-good revision:

1. Find the prior tag or commit SHA from GitHub deployment history or `git log`.
2. Re-run the `Deploy` workflow (or invoke `bigbase-deploy` manually) with `ref` set to that SHA/tag.
3. Confirm the health check step passes.

There is no automatic rollback in this action — failed health checks fail the job and leave the site as-is.

## Token rotation

`BIGBASE_DEPLOY_TOKEN` is a long-lived scoped secret (OIDC does not apply — BigBase is a custom API, not AWS/GCP/Azure). Rotate on a calendar cadence (e.g. quarterly): provision a new token via `bigbase_provision_ci_credentials`, update the repo secret, revoke the old token.

## Migration status

All known repos migrated to scoped `BIGBASE_DEPLOY_TOKEN` as of 2026-07-10:
- `big-bolao` — migrated (commit b63fa5b)
- `big-library` — migrated (commit 0a43f24)
- `big-olive-books` — migrated (eslint.config.js + ci-cd.yml token auth)

No repos remain on `BIGBASE_EMAIL`/`BIGBASE_PASSWORD` auth. See `docs/reference/audit-history/2026-07-audit.md` for the original audit finding.
