---
type: Reference
title: Audit History — Portfolio Security and Infrastructure Audits
description: Consolidated audit findings and research for the danielvm-git portfolio, organized by date.
tags: [audit, security, portfolio, github-actions, contabo]
timestamp: 2026-07-13
provenance: docs/reference/audit-history/ (consolidated)
---

# Audit History

## Overview

Consolidated audit findings and research for the danielvm-git portfolio. Entries are date-grouped, newest first.

---

## 2026-07

### GitHub Actions Audit

Full audit, based on the actual local clones in `/Users/danielvm/Developer` rather than the GitHub API (which rate-limited at 60 req/hr unauthenticated). Scanned all 28 repos from the dashboard; 22 have `.github/workflows`, 54 workflow files total. 6 repos have no CI at all: `big-clipboard-manager`, `big-kickass-readme`, `big-server-monitor`, `bigpowers-showcase`, `clean-install-guide`, `skill-method-manager`.

#### Portfolio-wide numbers

| Check | Result |
|-------|--------|
| Workflow files scanned | 54, across 22 repos |
| Missing a `permissions:` block entirely | 28 of 54 (52%) |
| No `timeout-minutes` anywhere in the file | 45 of 54 (83%) |
| No `concurrency` group | 40 of 54 (74%) |
| Uses `ubuntu-latest`/`macos-latest`/`windows-latest` | 52 of 54 (96%) |
| Third-party action pinned to a tag, not a SHA | 11 files, 16 occurrences |

#### What you're doing right

Least-privilege permissions are set almost everywhere. The two highest-risk third-party actions (with write access to `gh-pages`) are already pinned to full commit SHAs. `release-deploy.yml` has a genuinely good deployment pattern: backup → deploy → health-check → rollback.

#### Unpinned third-party actions, by risk

| Repo | File | Action | Risk |
|------|------|--------|------|
| bigbase | release-deploy.yml | `appleboy/scp-action@v0.1.7`, `appleboy/ssh-action@v1.2.2` | **Highest** — holds Contabo SSH key |
| sqz | release.yml | `softprops/action-gh-release@v2` | Medium |
| big-personal-finance | ci.yml | `codecov/codecov-action@v4` | Low-medium |
| sqz | benchmarks.yml, docs.yml, release.yml | `dtolnay/rust-toolchain@master`/`@stable` | **Notable** — worst pinning practice |
| Various | varied | `pnpm/action-setup@v4`/`@v2`, `Swatinem/rust-cache@v2` | Low |

#### Gaps, ranked by impact

1. **Deploy-time third-party actions aren't SHA-pinned** (highest impact)
2. **No concurrency guard on deploy**
3. **Missing `timeout-minutes` in several places**
4. **`-latest` runners in 3 of 4 workflows**
5. **No `cancel-in-progress` concurrency on CI jobs**
6. **Docker-based third-party action pinned to a version tag, not a digest**

#### Recommended fix order

1. SHA-pin `appleboy/scp-action` and `appleboy/ssh-action` in `bigbase/release-deploy.yml`
2. Fix `sqz`'s `dtolnay/rust-toolchain@master`/`@stable`
3. Add `permissions: contents: read` to 28 files missing it
4. Add `timeout-minutes` and `concurrency` group as shared template
5. Consider reusable `workflow_call` template

---

### Contabo API Research — VPS Monitoring & Security

Research conducted 2026-07-12 on Contabo API capabilities for bigbase VPS monitoring and maintenance.

#### Source URLs

- [Contabo API Overview](https://api.contabo.com/#section/Introduction/API-Overview)
- [Instance Actions Audits](https://api.contabo.com/#tag/Instance-Actions-Audits/operation/retrieveInstancesActionsAuditsList)
- [Checks](https://api.contabo.com/#tag/Checks)
- [SSH Setup Guide](https://help.contabo.com/en/support/solutions/articles/103000271398-how-do-i-set-up-an-ssh-connection-)

#### Key findings

| Topic | Finding |
|-------|---------|
| Authentication | OAuth2 password grant with 4 credentials |
| CLI tool | `cntb` supports macOS, Windows, Linux |
| Instance management | 14 status values, 5 action types |
| Troubleshooting API | **Opaque** — docs don't specify what checks monitor |
| Package management | **Not available** via API — must use SSH |
| Kernel updates | **Not available** via API — must use SSH |
| Security monitoring | **Not available** via API — must use SSH |

#### Implications for bigbase

1. **VPS health monitoring**: Must be done via SSH (not API)
2. **Security updates**: Must be done via SSH
3. **Automatic updates**: `unattended-upgrades` is recommended
4. **Snapshots**: Contabo API can create snapshots — useful for rollback
5. **SSH key authentication**: Strongly recommended over passwords

#### Grilled claims

| Claim | Verified? |
|-------|-----------|
| Authentication uses OAuth2 password grant | Yes |
| `cntb` CLI exists | Yes |
| Instance status values | Yes — all 14 confirmed |
| Checks are "health checks" | **No** — docs don't specify |
| Remedies auto-trigger on check failure | **No** — not documented |
| Ubuntu updates via API | **No** — requires SSH |

#### Recommendations

1. Set up `unattended-upgrades` on bigbase VPS for automatic security patches
2. Use SSH key authentication (ed25519) instead of passwords
3. Create snapshots via Contabo API before major changes
4. Monitor bigbase health via SSH (`systemctl status bigbase`, `journalctl`)
5. Do NOT rely on Contabo Troubleshooting API for automated health checks

## References

- [branch-protection-rules.md](branch-protection-rules.md) — Branch protection setup
- [BigBase Deploy Contract](contracts/bigbase-deploy-contract.md) — Deploy contract
- [Contabo API Contract](contracts/contabo-api-contract.md) — API contract
