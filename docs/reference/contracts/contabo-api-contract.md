---
type: reference
title: Contabo API contract
---

# Contabo API contract

Reference for Contabo API credentials, endpoints, and capabilities relevant to bigbase VPS management.

## Required secrets (for API access)

| Secret | Notes |
|---|---|
| `CONTABO_CLIENT_ID` | From Customer Control Panel → API Details |
| `CONTABO_CLIENT_SECRET` | From Customer Control Panel → API Details |
| `CONTABO_API_USER` | Your email address (same as Control Panel login) |
| `CONTABO_API_PASSWORD` | Set separately in Control Panel, NOT your account password |

## Required secrets (for SSH access)

| Secret | Notes |
|---|---|
| `CONTABO_HOST` | VPS IP address |
| `CONTABO_USER` | Typically `root` |
| `CONTABO_SSH_KEY` | Private key for SSH authentication |

## API capabilities

| Capability | Available? | Notes |
|---|---|---|
| Instance lifecycle (start/stop/restart) | Yes | Via API or `cntb` CLI |
| Instance status check | Yes | 14 status values including `running`, `stopped`, `error` |
| Snapshot creation/revert | Yes | For backups before changes |
| Audit history | Yes | Track API-triggered actions |
| OS package management | **No** | Must use SSH (`apt update && apt upgrade`) |
| Kernel updates | **No** | Must use SSH |
| Security monitoring | **No** | Contabo Troubleshooting API is opaque |

## Authentication flow

```
POST https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token
  grant_type=password
  client_id=<ClientId>
  client_secret=<ClientSecret>
  username=<API User>
  password=<API Password>

Response: { access_token, token_type, expires_in, ... }
```

## CLI tool: `cntb`

```bash
# Install
brew install contabo/tap/cntb  # macOS
# Or download from https://github.com/contabo/cntb

# Configure
cntb config set-credentials \
  --oauth2-clientid=<ClientId> \
  --oauth2-client-secret=<ClientSecret> \
  --oauth2-user=<API User> \
  --oauth2-password='<API Password>'

# Usage
cntb get instances              # List instances
cntb get instance <id>          # Get specific instance
cntb create snapshot --instance-id <id> --name "backup"
```

## Instance status enum

```
provisioning | uninstalled | running | stopped | error | installing |
unknown | manual_provisioning | product_not_available |
verification_required | rescue | pending_payment | other | reset_password
```

## Troubleshooting API (experimental)

**Caveat**: Docs don't specify what checks actually monitor. Use with caution.

```bash
# Run check against vserver
curl -X POST "https://api.contabo.com/v1/troubleshooting/checks" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{"objectType": "vserver", "objectId": <INSTANCE_ID>, "checkTemplateId": <TEMPLATE_ID>}'

# Trigger remedy (e.g., restart)
curl -X POST "https://api.contabo.com/v1/troubleshooting/remedies" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d '{"objectType": "vserver", "objectId": <INSTANCE_ID>, "remedyTemplateId": <TEMPLATE_ID>}'
```

## What's NOT available via API

- `apt` / `dpkg` package management
- `systemctl` service management
- Log viewing
- File system access
- Network configuration
- User management on the VPS itself

All of these require SSH access.

## References

- [Contabo API docs](https://api.contabo.com/)
- [Contabo CLI (cntb)](https://github.com/contabo/cntb)
- [SSH setup guide](https://help.contabo.com/en/support/solutions/articles/103000271398-how-do-i-set-up-an-ssh-connection-)
- `docs/reference/contabo-vps-api.md` for detailed API reference
