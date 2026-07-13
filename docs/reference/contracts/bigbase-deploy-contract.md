---
type: Reference
title: BigBase Deploy Contract
description: Contract specification for the bigbase-deploy action — secrets, app_type values, and health check protocol.
tags: [deploy, contract, bigbase, ci-cd]
timestamp: 2026-07-13
---

# BigBase Deploy Contract

## Overview

This document defines the contract between the `bigbase-deploy` GitHub Action and the repos that consume it. Every project deploying to BigBase must follow these conventions.

## Required repo secrets

| Secret | Notes |
|--------|-------|
| `BIGBASE_DEPLOY_TOKEN` | Scoped to one site. Provision via `bigbase_provision_ci_credentials`. Never use account email/password. |
| `BIGBASE_SITE_ID` | The site this token is scoped to. |

## App_type values in use

| Value | Used by |
|-------|---------|
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

## References

- [Audit History](../audit-history.md) — Original audit finding
