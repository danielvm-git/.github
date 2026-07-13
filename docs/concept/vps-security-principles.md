---
type: Concept
title: VPS Security Principles for Portfolio Projects
description: Security principles and defense layers for the bigbase Contabo VPS that serves all portfolio projects.
tags: [vps, security, bigbase, contabo, infrastructure]
timestamp: 2026-07-13
provenance: docs/explanation/vps-security-principles.md
story: e01s02
---

# VPS Security Principles for Portfolio Projects

## Overview

This document explains why and how we secure the bigbase VPS — the central application server hosted on Contabo (6 vCPU/16GB RAM, EU region). It serves all `*.bigbase.click` domains via Caddy reverse proxy, a SQLite database, and a Go binary managed by systemd. As the only production VPS in the portfolio, its security posture affects all deployed projects.

## Defense layers

```text
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
- `unattended-upgrades` can be configured for security-only patches

## Why Contabo API is limited for security

The Contabo API provides instance lifecycle management and snapshot capabilities but does NOT provide OS package management, kernel updates, or security monitoring. SSH access with key authentication remains the primary security boundary.

## Why snapshots matter

Before major changes (kernel updates, config changes):
1. Create snapshot via Contabo API or Control Panel
2. Apply changes
3. If something breaks, revert to snapshot

```bash
cntb create snapshot --instance-id <ID> --name "pre-update-YYYY-MM-DD"
```

## References

- [Contabo VPS API Reference](../api-reference/contabo-vps-api.md) — API details
- [VPS Security Updates How-to](../how-to/vps-security-updates.md) — Update setup
- [Contabo SSH setup guide](https://help.contabo.com/en/support/solutions/articles/103000271398-how-do-i-set-up-an-ssh-connection-)
