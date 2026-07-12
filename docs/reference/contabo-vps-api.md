---
type: reference
title: Contabo VPS API reference
---

# Contabo VPS API reference

Cross-reference for the Contabo API relevant to bigbase VPS management. Verified against official docs (2026-07-12).

## Authentication

OAuth2 password grant at `https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token`.

| Credential | Source |
|---|---|
| `ClientId` | Customer Control Panel → API Details |
| `ClientSecret` | Customer Control Panel → API Details |
| `API User` | Your email address |
| `API Password` | Set separately in Control Panel |

```bash
# Get access token
ACCESS_TOKEN=$(curl -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  --data-urlencode "username=$API_USER" \
  --data-urlencode "password=$API_PASSWORD" \
  -d 'grant_type=password' \
  'https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token' \
  | jq -r '.access_token')
```

## CLI tool: `cntb`

Install from [github.com/contabo/cntb](https://github.com/contabo/cntb). Supports macOS, Windows, Linux.

```bash
# Configure credentials
cntb config set-credentials \
  --oauth2-clientid=<ClientId> \
  --oauth2-client-secret=<ClientSecret> \
  --oauth2-user=<API User> \
  --oauth2-password='<API Password>'

# List instances
cntb get instances
```

## Instance status values

| Status | Meaning |
|---|---|
| `running` | Instance is active |
| `stopped` | Instance is shut down |
| `error` | Instance has an error |
| `provisioning` | Being set up |
| `installing` | OS installation in progress |
| `rescue` | In rescue mode |
| `unknown` | Status unavailable |

Full enum: provisioning, uninstalled, running, stopped, error, installing, unknown, manual_provisioning, product_not_available, verification_required, rescue, pending_payment, other, reset_password.

## Instance actions

| Endpoint | Method | Purpose |
|---|---|---|
| `/v1/compute/instances` | GET | List all instances |
| `/v1/compute/instances/{id}` | GET | Get specific instance |
| `/v1/compute/instances/{id}/actions/audits` | GET | History of API-triggered actions |
| `/v1/compute/instances/{id}/snapshots` | POST | Create snapshot |
| `/v1/compute/instances/{id}/snapshots/{snapId}/revert` | POST | Revert to snapshot |

## Troubleshooting API (opaque)

**Caveat**: Docs don't specify what checks actually monitor. Use with caution.

| Endpoint | Method | Purpose |
|---|---|---|
| `/v1/troubleshooting/checks` | POST | Run check against vserver |
| `/v1/troubleshooting/checks/{id}` | GET | Get check result |
| `/v1/troubleshooting/check-collections` | POST | Run bundled checks |
| `/v1/troubleshooting/remedies` | POST | Trigger remedy (e.g., restart) |

### Check statuses

`queued`, `running`, `skipped`, `cancelled`, `failed`, `warn`, `successful`

### Important notes

- Checks require `objectType: "vserver"` and `objectId` (your instance ID)
- Check responses include `remedyTemplates` (e.g., "Instance restart remedy")
- Auto-remediation on check failure is NOT documented
- Available check/remedy templates are not documented — contact Contabo support

## Ubuntu security updates

Ubuntu package updates are NOT available via the Contabo API. Must be done via SSH:

```bash
# Manual update
sudo apt update && sudo apt upgrade -y

# Enable automatic security updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

See `docs/how-to/vps-security-updates.md` for full setup.

## Secrets management

Use Contabo's Secrets API to store SSH keys and passwords centrally. Secrets are referenced by ID when creating/reinstalling instances.

## References

- [Contabo API docs](https://api.contabo.com/)
- [Contabo CLI (cntb)](https://github.com/contabo/cntb)
- [SSH setup guide](https://help.contabo.com/en/support/solutions/articles/103000271398-how-do-i-set-up-an-ssh-connection-)
