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
| node / go | not yet exercised live — confirm behavior before relying on it |

## Health check contract

8 attempts, 10s interval, accepts HTTP 200/301/302 as healthy. Failing after 8 attempts fails the job — no silent partial-deploy state.

## Known migration debt

`big-library`, `big-olive-books` still authenticate with `BIGBASE_EMAIL`/`BIGBASE_PASSWORD` as of the 2026-07 audit. `big-bolao` migrated to `BIGBASE_DEPLOY_TOKEN` on 2026-07-10. See `docs/reference/audit-history/2026-07-audit.md` for the full audit finding.
