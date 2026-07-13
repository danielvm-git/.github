---
type: Troubleshooting
title: Deploy Health Check Failures
description: Diagnose and fix common failures when deploying with the bigbase-deploy action — health check timeout, wrong app_type, missing token, and 404 after deploy.
tags: [deploy, health-check, troubleshooting, bigbase, contabo]
timestamp: 2026-07-13
provenance: docs/api-reference/contabo-vps-api.md
story: e01s04
---

# Deploy Health Check Failures

## Overview

The `bigbase-deploy` action validates a deployment by hitting the target URL after the deploy step. If the health check fails, the action marks the deployment as failed and rolls back. This guide covers the four most common failure modes.

---

## Health check timeout

### Symptom

The deploy log shows:

```
Waiting for health check... Request timed out after 30 seconds.
```

The action exits with a non-zero code and the deployment is marked failed.

### Cause

The health check URL is unreachable from GitHub's runner network. Common reasons:

- The VPS firewall (UFW) blocks port 80 or 443 from GitHub's IP range.
- The application takes longer than the default 30-second timeout to start.
- The DNS record for the domain has not propagated yet.

### Fix

1. Verify the application is running on the VPS:

   ```bash
   ssh deploy@<vps-ip> 'systemctl status <app-name>'
   ```

2. Check that the firewall allows HTTP/HTTPS:

   ```bash
   ssh deploy@<vps-ip> 'sudo ufw status | grep -E "80|443"'
   ```

   If missing, add rules:

   ```bash
   ssh deploy@<vps-ip> 'sudo ufw allow 80/tcp && sudo ufw allow 443/tcp'
   ```

3. Increase the health check timeout in the workflow:

   ```yaml
   - uses: danielvm-git/bigbase-deploy@v1
     with:
       health-check-timeout: 60
   ```

4. If the app starts slowly, add a readiness endpoint that returns 200 only after initialization completes.

---

## Wrong app_type

### Symptom

The deploy succeeds but the health check returns a non-200 status code (e.g., 502 Bad Gateway), or the action logs:

```
Health check returned 502 — expected 200.
```

### Cause

The `app_type` input passed to `bigbase-deploy` does not match the actual application. For example, setting `app_type: static` for a Node.js API that needs a process manager, or `app_type: node` for a Go binary.

### Fix

1. Check the application type in the repo's `CONTRIBUTING.md` or `Makefile`:

   ```bash
   head -20 Makefile
   ```

2. Set the correct `app_type` in the deploy workflow:

   | App type | Typical files        | Use case               |
   |----------|----------------------|------------------------|
   | `static` | `index.html`, `_site/` | Static site (Jekyll, Hugo) |
   | `node`   | `package.json`, `server.js` | Node.js/Express API  |
   | `go`     | `go.mod`, `main.go`  | Go binary              |
   | `docker` | `Dockerfile`         | Docker container       |

   ```yaml
   - uses: danielvm-git/bigbase-deploy@v1
     with:
       app_type: node
   ```

---

## Missing token

### Symptom

The deploy log shows:

```
Error: No deploy token found. Set DEPLOY_TOKEN secret.
```

The action exits before attempting the deploy.

### Cause

The `DEPLOY_TOKEN` repository secret has not been set, or the secret is misspelled. The `bigbase-deploy` action requires this token to authenticate with the target VPS.

### Fix

1. Go to the repository on GitHub: **Settings → Secrets and variables → Actions**.
2. Add a new repository secret named `DEPLOY_TOKEN` with the value from the VPS deploy key store.
3. Verify the secret is available by checking that the workflow has:

   ```yaml
   - uses: danielvm-git/bigbase-deploy@v1
     with:
       deploy-token: ${{ secrets.DEPLOY_TOKEN }}
   ```

4. Re-run the failed workflow.

---

## 404 after deploy

### Symptom

The deploy completes successfully but the health check returns HTTP 404. The action logs:

```
Health check returned 404 — expected 200.
```

### Cause

The deployed application is running, but the health check URL path does not exist. Common causes:

- The app serves on a different base path (e.g., `/app` instead of `/`).
- The web server root points to the wrong directory.
- A reverse proxy (Nginx, Caddy) forwards to the wrong upstream port.

### Fix

1. Verify the correct URL by curling from the VPS itself:

   ```bash
   ssh deploy@<vps-ip> 'curl -s -o /dev/null -w "%{http_code}" http://localhost:<port>/'
   ```

2. Check the web server configuration for the correct root or proxy pass:

   ```bash
   ssh deploy@<vps-ip> 'cat /etc/nginx/sites-enabled/default | grep -E "root|proxy_pass"'
   ```

3. Update the health check URL in the workflow to match the app's actual path:

   ```yaml
   - uses: danielvm-git/bigbase-deploy@v1
     with:
       health-check-url: https://example.com/health
   ```
