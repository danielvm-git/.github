---
type: How-to
title: Keep Ubuntu VPS Secure with Automatic Updates
description: How to configure automatic security updates on the bigbase Contabo VPS to reduce exposure to known vulnerabilities.
tags: [vps, security, ubuntu, unattended-upgrades, bigbase]
timestamp: 2026-07-13
provenance: docs/how-to/vps-security-updates.md
---

# Keep Ubuntu VPS Secure with Automatic Updates

## Overview

This guide explains how to configure automatic security updates on the bigbase Contabo VPS. Ubuntu releases security patches for known CVEs regularly, and unpatched servers are primary targets for automated scanners. Since the Contabo API does NOT provide package management, this must be done via SSH.

## Before you start

- SSH access to the bigbase VPS with `sudo` privileges
- SSH key authentication configured (not password)

## Step-by-step guide

### 1. Install unattended-upgrades

```bash
sudo apt update
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
# Select "Yes" when prompted
```

### 2. Verify it's running

```bash
sudo systemctl status unattended-upgrades
```

### 3. Configure for security-only updates

Edit `/etc/apt/apt.conf.d/50unattended-upgrades`:

```bash
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "04:00";
```

### 4. Enable the daily timer

```bash
sudo systemctl enable --now unattended-upgrades.timer
systemctl list-timers | grep unattended
```

## Monitoring updates

```bash
# Check pending security updates
apt list --upgradable 2>/dev/null | grep -i security

# Check unattended-upgrades logs
sudo journalctl -u unattended-upgrades --since "7 days ago"

# Verify service is active
sudo systemctl status unattended-upgrades
```

## For bigbase specifically

Since bigbase runs as a systemd service:
1. The service will restart automatically after kernel-update reboot
2. Caddy doesn't need action — binary updates are separate from OS packages
3. The Go binary is statically linked and doesn't depend on OS packages

```bash
sudo systemctl status bigbase
[ -f /var/run/reboot-required ] && echo "REBOOT NEEDED" || echo "No reboot required"
```

## Security hardening (beyond updates)

```bash
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban
```

## See also

- [VPS Security Principles](../concept/vps-security-principles.md) — Defense layers explained
- [Contabo VPS API Reference](../api-reference/contabo-vps-api.md) — API details
