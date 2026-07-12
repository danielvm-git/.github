# Contabo API Research — VPS Monitoring & Security

Research conducted 2026-07-12 on Contabo API capabilities for bigbase VPS monitoring and maintenance.

## Source URLs

- [Contabo API Overview](https://api.contabo.com/#section/Introduction/API-Overview)
- [Instance Actions Audits](https://api.contabo.com/#tag/Instance-Actions-Audits/operation/retrieveInstancesActionsAuditsList)
- [Checks](https://api.contabo.com/#tag/Checks)
- [Check Collection Templates](https://api.contabo.com/#tag/Check-Collection-Templates)
- [Remedies](https://api.contabo.com/#tag/Remedies)
- [SSH Setup Guide](https://help.contabo.com/en/support/solutions/articles/103000271398-how-do-i-set-up-an-ssh-connection-)

## Findings

### Authentication

OAuth2 password grant with 4 credentials from Customer Control Panel:
- ClientId, ClientSecret, API User (email), API Password (separate from account password)

### CLI tool: `cntb`

Available at [github.com/contabo/cntb](https://github.com/contabo/cntb). Supports macOS, Windows, Linux. Commands: `get instances`, `get instance <id>`, `create snapshot`, etc.

### Instance management

14 status values available. Actions: start, stop, restart, shutdown, rescue, reset password. Snapshots for backup/recovery.

### Troubleshooting API (opaque)

**Critical finding**: The Troubleshooting API exists but docs don't specify what checks actually monitor.

- Checks require `objectType: "vserver"` and `objectId`
- Check statuses: queued, running, skipped, cancelled, failed, warn, successful
- Check responses include `remedyTemplates` (e.g., "Instance restart remedy")
- Auto-remediation on check failure is NOT documented
- Available check/remedy templates are not documented

**Conclusion**: Cannot rely on Troubleshooting API for automated health monitoring without contacting Contabo support.

### What's NOT available via API

- OS package management (`apt`, `dpkg`)
- Kernel updates
- Security monitoring
- Log viewing
- Service management (`systemctl`)
- File system access

All require SSH access.

## Implications for bigbase

1. **VPS health monitoring**: Must be done via SSH (not API) — check `systemctl status bigbase`, `journalctl -u bigbase`, disk/memory/CPU
2. **Security updates**: Must be done via SSH (`sudo apt update && sudo apt upgrade`)
3. **Automatic updates**: `unattended-upgrades` is the recommended approach for security patches
4. **Snapshots**: Contabo API can create snapshots before major changes — useful for rollback
5. **SSH key authentication**: Strongly recommended over passwords (Contabo docs confirm this)

## Grilled claims (verified via grill-with-docs)

| Claim | Verified? | Notes |
|---|---|---|
| Authentication uses OAuth2 password grant | Yes | Docs confirm |
| `cntb` CLI exists | Yes | Docs confirm |
| Instance status values | Yes | All 14 confirmed |
| Checks are "health checks" | **No** | Docs don't specify what they check |
| Remedies auto-trigger on check failure | **No** | Not documented |
| Check Collection Templates bundle checks | Yes | But contents unknown |
| Ubuntu updates via API | **No** | Requires SSH |

## Recommendations

1. Set up `unattended-upgrades` on bigbase VPS for automatic security patches
2. Use SSH key authentication (ed25519) instead of passwords
3. Create snapshots via Contabo API before major changes
4. Monitor bigbase health via SSH (`systemctl status bigbase`, `journalctl`)
5. Do NOT rely on Contabo Troubleshooting API for automated health checks
