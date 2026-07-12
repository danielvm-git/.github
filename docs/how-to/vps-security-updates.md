---
type: how-to
title: Keep Ubuntu VPS secure with automatic updates
---

# Keep Ubuntu VPS secure with automatic updates

How to configure automatic security updates on the bigbase Contabo VPS to reduce exposure to known vulnerabilities.

## Why this matters

- Ubuntu releases security patches for known CVEs
- Unpatched servers are primary targets for automated scanners
- bigbase runs a Go binary + Caddy + SQLite — OS-level packages (OpenSSL, systemd, kernel) still need patching
- Contabo API does NOT provide package management — must be done via SSH

## Quick setup (recommended)

```bash
# Install and enable unattended-upgrades
sudo apt update
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
# Select "Yes" when prompted

# Verify it's running
sudo systemctl status unattended-upgrades
```

## Configure for security-only updates

Edit `/etc/apt/apt.conf.d/50unattended-upgrades`:

```bash
# Only install security updates (not all packages)
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};

# Auto-remove old kernels
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";

# Enable automatic reboot for kernel updates (4 AM)
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "04:00";
```

## Enable automatic updates via timer

```bash
# Enable the daily update timer
sudo systemctl enable --now unattended-upgrades.timer

# Check timer status
systemctl list-timers | grep unattended
```

## Manual commands

| Command | Purpose |
|---|---|
| `sudo apt update` | Refresh package lists |
| `apt list --upgradable` | See available updates |
| `sudo apt upgrade -y` | Apply all updates |
| `sudo apt install unattended-upgrades` | Install auto-update package |
| `sudo unattended-upgrades --dry-run` | Test configuration |
| `sudo journalctl -u unattended-upgrades` | View update logs |

## Monitoring updates

```bash
# Check pending security updates
apt list --upgradable 2>/dev/null | grep -i security

# Check unattended-upgrades logs
sudo journalctl -u unattended-upgrades --since "7 days ago"

# Verify service is active
sudo systemctl status unattended-upgrades
```

## Optional: Email notifications

```bash
# Install mailutils
sudo apt install -y mailutils

# Add to /etc/apt/apt.conf.d/50unattended-upgrades:
Unattended-Upgrade::Mail "your-email@example.com";
Unattended-Upgrade::MailReport "on-change";
```

## Optional: Landscape sysinfo

```bash
# Install landscape-common for system status overview
sudo apt install -y landscape-common
landscape-sysinfo
```

## For bigbase specifically

Since bigbase runs as a systemd service:

1. **Before kernel updates**: Service will restart automatically after reboot
2. **Caddy**: No action needed — binary updates are separate from OS packages
3. **Go binary**: Compiled binary doesn't depend on OS packages (statically linked)

```bash
# Verify bigbase service survives reboot
sudo systemctl status bigbase

# Check if reboot is needed after updates
[ -f /var/run/reboot-required ] && echo "REBOOT NEEDED" || echo "No reboot required"
```

## Security hardening (beyond updates)

```bash
# Enable firewall
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https

# Install fail2ban
sudo apt install -y fail2ban
sudo systemctl enable --now fail2ban
```

## References

- [Ubuntu unattended-upgrades docs](https://help.ubuntu.com/community/SecurityUPgrades)
- [Canonical Livepatch](https://ubuntu.com/security/livepatch) (kernel patching without reboot)
- `docs/reference/contabo-vps-api.md` for API details
