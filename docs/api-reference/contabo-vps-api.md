---
type: API Reference
title: Contabo VPS API Reference
description: Cross-reference for the Contabo API relevant to bigbase VPS management — authentication, endpoints, and CLI.
tags: [contabo, api, reference, vps]
timestamp: 2026-07-13
provenance: docs/reference/contabo-vps-api.md
---

# Contabo VPS API Reference

## Overview

Cross-reference for the Contabo API relevant to bigbase VPS management. Verified against official docs (2026-07-12).

## Authentication

OAuth2 password grant at `https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token`.

| Credential | Source |
|-----------|--------|
| `ClientId` | Customer Control Panel → API Details |
| `ClientSecret` | Customer Control Panel → API Details |
| `API User` | Your email address |
| `API Password` | Set separately in Control Panel |

```bash
ACCESS_TOKEN=$(curl -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  --data-urlencode "username=$API_USER" \
  --data-urlencode "password=$API_PASSWORD" \
  -d 'grant_type=password' \
  'https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token' \
  | jq -r '.access_token')
```

## CLI tool: cntb

Install from [github.com/contabo/cntb](https://github.com/contabo/cntb).

```bash
cntb config set-credentials \
  --oauth2-clientid=<ClientId> \
  --oauth2-client-secret=<ClientSecret> \
  --oauth2-user=<API User> \
  --oauth2-password='<API Password>'
cntb get instances
```

## Instance status values

| Status | Meaning |
|--------|---------|
| `running` | Instance is active |
| `stopped` | Instance is shut down |
| `error` | Instance has an error |
| `provisioning` | Being set up |
| `installing` | OS installation in progress |
| `rescue` | In rescue mode |
| `unknown` | Status unavailable |

## Instance actions

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/v1/compute/instances` | GET | List all instances |
| `/v1/compute/instances/{id}` | GET | Get specific instance |
| `/v1/compute/instances/{id}/actions/audits` | GET | History of API-triggered actions |
| `/v1/compute/instances/{id}/snapshots` | POST | Create snapshot |
| `/v1/compute/instances/{id}/snapshots/{snapId}/revert` | POST | Revert to snapshot |

## Troubleshooting API

**Caveat**: Docs don't specify what checks actually monitor. Use with caution.

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/v1/troubleshooting/checks` | POST | Run check against vserver |
| `/v1/troubleshooting/checks/{id}` | GET | Get check result |
| `/v1/troubleshooting/check-collections` | POST | Run bundled checks |
| `/v1/troubleshooting/remedies` | POST | Trigger remedy (e.g., restart) |

## Ubuntu security updates

Ubuntu package updates are NOT available via the Contabo API. Must be done via SSH:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

## Secrets management

Use Contabo's Secrets API to store SSH keys and passwords centrally.

## References

- [Contabo API docs](https://api.contabo.com/)
- [Contabo CLI (cntb)](https://github.com/contabo/cntb)
- [SSH setup guide](https://help.contabo.com/en/support/solutions/articles/103000271398-how-do-i-set-up-an-ssh-connection-)
- [VPS Security Principles](../concept/vps-security-principles.md)
- [VPS Security Updates How-to](../how-to/vps-security-updates.md)
