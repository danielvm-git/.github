---
type: explanation
title: VPS security principles for portfolio projects
---

# VPS security principles for portfolio projects

Why we maintain the bigbase VPS with automatic updates and SSH key authentication.

## Context

bigbase is the central application repo deployed to a Contabo VPS (6 vCPU/16GB RAM, EU region). It serves:
- `*.bigbase.click` domains via Caddy reverse proxy
- SQLite database
- Go binary managed by systemd

As the only production VPS in the portfolio, its security posture affects all deployed projects.

## Defense layers

```
┌─────────────────────────────────────┐
│  Contabo API                        │  Instance management, snapshots
├─────────────────────────────────────┤
│  SSH (key auth only)                │  No passwords, ed25519 keys
├─────────────────────────────────────┤
│  UFW firewall                       │  Only ssh/http/https open
├─────────────────────────────────────┤
│  unattended-upgrades                │  Automatic security patches
├─────────────────────────────────────┤
│  fail2ban                           │  Brute-force protection
├─────────────────────────────────────┤
│  systemd service                    │  Auto-restart on failure
├─────────────────────────────────────┤
│  Caddy TLS                          │  On-demand TLS, auto-renewal
└─────────────────────────────────────┘
```

## Why SSH keys over passwords

- Private keys are computationally infeasible to brute-force
- Passwords are never transmitted over the network
- Automated login attempts fail without the private key
- Password auth can be disabled entirely after key setup

## Why automatic security updates

- Ubuntu publishes security patches for known CVEs promptly
- Unpatched servers are primary targets for automated scanners
- Manual updates require human discipline — automation removes this dependency
- `unattended-upgrades` can be configured for security-only patches to avoid breaking changes

## Why Contabo API is limited for security

The Contabo API provides:
- Instance lifecycle (start/stop/restart/reinstall)
- Snapshot management
- Audit history

It does NOT provide:
- OS package management (apt/dpkg)
- Kernel updates
- Security monitoring

Therefore, SSH access with key authentication remains the primary security boundary.

## Why snapshots matter

Before major changes (kernel updates, config changes):
1. Create snapshot via Contabo API or Control Panel
2. Apply changes
3. If something breaks, revert to snapshot

```bash
# Create snapshot via cntb
cntb create snapshot --instance-id <ID> --name "pre-update-YYYY-MM-DD"
```

## References

- `docs/reference/contabo-vps-api.md` — API details
- `docs/how-to/vps-security-updates.md` — Update setup
- [Contabo SSH setup guide](https://help.contabo.com/en/support/solutions/articles/103000271398-how-do-i-set-up-an-ssh-connection-)
