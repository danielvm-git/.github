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

## `app_type` values in use

| Value | Used by |
|---|---|
| `static` | Astro/Vue/plain static builds |
| `python` | big-bolao |
| `go` | big-library (MCP server) |
| `node` | not yet exercised live — confirm behavior before relying on it |

## Health check contract

8 attempts, 10s interval, accepts HTTP 200/301/302 as healthy. Failing after 8 attempts fails the job — no silent partial-deploy state.

## Migration status

All known repos migrated to scoped `BIGBASE_DEPLOY_TOKEN` as of 2026-07-10:
- `big-bolao` — migrated (commit b63fa5b)
- `big-library` — migrated (commit 0a43f24)
- `big-olive-books` — migrated (eslint.config.js + ci-cd.yml token auth)

No repos remain on `BIGBASE_EMAIL`/`BIGBASE_PASSWORD` auth. See `docs/reference/audit-history/2026-07-audit.md` for the original audit finding.
