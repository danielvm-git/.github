---
type: Reference
title: Contabo API Contract
description: Reference for Contabo API credentials, endpoints, and capabilities relevant to bigbase VPS management.
tags: [contabo, api, contract, vps, infrastructure]
timestamp: 2026-07-13
---

# Contabo API Contract

## Overview

This document defines the contract for interacting with the Contabo API for bigbase VPS management. It covers required secrets, API capabilities, authentication flow, and limitations.

## Required secrets

### API access

| Secret | Notes |
|--------|-------|
| `CONTABO_CLIENT_ID` | From Customer Control Panel → API Details |
| `CONTABO_CLIENT_SECRET` | From Customer Control Panel → API Details |
| `CONTABO_API_USER` | Your email address (same as Control Panel login) |
| `CONTABO_API_PASSWORD` | Set separately in Control Panel, NOT your account password |

### SSH access

| Secret | Notes |
|--------|-------|
| `CONTABO_HOST` | VPS IP address |
| `CONTABO_USER` | Typically `root` |
| `CONTABO_SSH_KEY` | Private key for SSH authentication |

## API capabilities

| Capability | Available? | Notes |
|-----------|-----------|-------|
| Instance lifecycle (start/stop/restart) | Yes | Via API or `cntb` CLI |
| Instance status check | Yes | 14 status values |
| Snapshot creation/revert | Yes | For backups before changes |
| Audit history | Yes | Track API-triggered actions |
| OS package management | **No** | Must use SSH |
| Kernel updates | **No** | Must use SSH |
| Security monitoring | **No** | Contabo Troubleshooting API is opaque |

## Authentication flow

```text
POST https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token
  grant_type=password
  client_id=<ClientId>
  client_secret=<ClientSecret>
  username=<API User>
  password=<API Password>
```

## CLI tool: cntb

```bash
brew install contabo/tap/cntb  # macOS
cntb config set-credentials \
  --oauth2-clientid=<ClientId> \
  --oauth2-client-secret=<ClientSecret> \
  --oauth2-user=<API User> \
  --oauth2-password='<API Password>'
cntb get instances
```

## What's NOT available via API

- `apt` / `dpkg` package management
- `systemctl` service management
- Log viewing
- File system access
- Network configuration
- User management on the VPS itself

## References

- [Contabo VPS API Reference](../api-reference/contabo-vps-api.md) — Detailed API reference
- [Contabo API docs](https://api.contabo.com/)
- [Contabo CLI (cntb)](https://github.com/contabo/cntb)
