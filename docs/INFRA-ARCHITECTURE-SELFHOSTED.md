# 🏗️ Infraestrutura Self-Hosted — Git + CI/CD + Deploy

> Arquitetura completa com Forgejo (Git self-hosted), staging e produção em 2 VPS.

## TL;DR

```
VPS-B (12GB/4c) → Forgejo (Git) + BigBase Staging     ← dev hub
VPS-A (16GB/6c) → BigBase Produção                     ← tráfego real
Custo total: ~$20-25/mês (vs GitHub Team $240/ano)
```

---

## 1. Por que Forgejo e não GitHub?

| Critério | GitHub | Forgejo (self-hosted) |
|----------|--------|----------------------|
| **Custo** | $4/user/mês (Team) | $0 (self-hosted) |
| **Dados** | Servidores dos EUA | Seu VPS, seu controle |
| **CI/CD** | GitHub Actions (2000 min free) | Forgejo Actions (ilimitado, seus runners) |
| **Privacidade** | Microsoft/GitHub ToS | Seus dados, suas regras |
| **Dependência** | Vendor lock-in | Open source, migra livre |
| **RAM usage** | N/A (SaaS) | ~400MB idle, ~1GB durante CI |
| **GitHub Actions YAML** | Nativo | 95% compatível (quase plug-and-play) |

### Por que Forgejo e não Gitea ou GitLab?

| Forge | RAM idle | CI built-in | Governance | Para seu caso |
|-------|----------|-------------|------------|---------------|
| **Forgejo** ✅ | ~400MB | Forgejo Actions | Non-profit (Codeberg e.V.) | Melhor custo-benefício |
| Gitea | ~400MB | Gitea Actions | For-profit (Gitea Ltd) | Funciona, mas trajectory pior |
| GitLab CE | **6.1GB** | GitLab CI | For-profit | Pesado demais para 12GB VPS |

**Recomendação: Forgejo** — lightweight, aceita GitHub Actions YAML, governança não-lucrativa, patches de segurança mais rápidos que Gitea.

---

## 2. Arquitetura Final — Diagrama Completo

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│                        VPS-B (12GB RAM / 4 cores)                               │
│                        IP: stg.bigbase.click                                    │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                        Forgejo (Git Server)                               │  │
│  │                        RAM: ~400MB idle, ~1GB CI                          │  │
│  │                                                                           │  │
│  │  git.bigbase.click                                                        │  │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐            │  │
│  │  │ repo 1  │ │ repo 2  │ │ repo 3  │ │   ...   │ │ repo 58 │            │  │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘            │  │
│  │                                                                           │  │
│  │  Forgejo Actions Runner (CI)                                              │  │
│  │  ┌─────────────────────────────────────────────────────────┐              │  │
│  │  │  • Lint → Test → Build → Deploy Staging (auto)         │              │  │
│  │  │  • Aceita GitHub Actions YAML (95% compatível)         │              │  │
│  │  │  • RAM durante CI: ~500MB-1GB por job                   │              │  │
│  │  └─────────────────────────────────────────────────────────┘              │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                     BigBase Staging Instance                              │  │
│  │                     RAM: ~2-3GB                                           │  │
│  │                                                                           │  │
│  │  stg.bigbase.click                                                        │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                    │  │
│  │  │  deploy  │ │   auth   │ │    db    │ │monitoring│                    │  │
│  │  │ (staging)│ │  (JWT)   │ │ (SQLite) │ │  (basic) │                    │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘                    │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                 │
│  RAM Budget (12GB):                                                            │
│  ├── Forgejo + Runner: 1.5GB                                                  │
│  ├── BigBase Staging: 2.5GB                                                   │
│  ├── Web apps (staging): 5GB                                                  │
│  ├── OS + system: 1.5GB                                                       │
│  └── Buffer: 1.5GB                                                            │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘

                                    │
                                    │ deploy-promote (manual ou auto)
                                    ▼

┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│                        VPS-A (16GB RAM / 6 cores)                               │
│                        IP: bigbase.click                                        │
│                                                                                 │
│  ┌───────────────────────────────────────────────────────────────────────────┐  │
│  │                     BigBase Production Instance                           │  │
│  │                     RAM: ~4-6GB                                           │  │
│  │                                                                           │  │
│  │  bigbase.click                                                            │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                    │  │
│  │  │  deploy  │ │   auth   │ │    db    │ │ storage  │                    │  │
│  │  │ (prod)   │ │  (JWT)   │ │ (Postgr.)│ │ (files)  │                    │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘                    │  │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                    │  │
│  │  │functions │ │ realtime │ │ webhooks │ │monitoring│                    │  │
│  │  │(serverl.)│ │  (WS)    │ │ (events) │ │ (alerts) │                    │  │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘                    │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                 │
│  RAM Budget (16GB):                                                            │
│  ├── BigBase Production: 4GB                                                  │
│  ├── Web apps (prod): 8GB                                                     │
│  ├── Database (prod): 2GB                                                     │
│  ├── OS + monitoring: 1GB                                                     │
│  └── Buffer: 1GB                                                              │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│                          Developer Machines (Local)                             │
│                                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                         │
│  │  Mac dev 1   │  │  Mac dev 2   │  │  Mac dev N   │                         │
│  │              │  │              │  │              │                         │
│  │  git clone   │  │  git clone   │  │  git clone   │                         │
│  │  from Forgejo│  │  from Forgejo│  │  from Forgejo│                         │
│  │              │  │              │  │              │                         │
│  │  localhost:  │  │  localhost:  │  │  localhost:  │                         │
│  │  3000/5173   │  │  3000/5173   │  │  3000/5173   │                         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                         │
│         │                 │                 │                                  │
│         └─────────────────┼─────────────────┘                                  │
│                           │                                                    │
│                    git push / PR                                                │
│                           │                                                    │
│                           ▼                                                    │
│                    Forgejo (VPS-B)                                              │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Fluxo de Código — Feature to Production

```
 Developer              Forgejo (VPS-B)          CI Runner (VPS-B)       BigBase Stg (VPS-B)     BigBase Prod (VPS-A)
    │                       │                        │                        │                        │
    │  1. git push          │                        │                        │                        │
    │  feature/my-branch    │                        │                        │                        │
    ├──────────────────────▶│                        │                        │                        │
    │                       │                        │                        │                        │
    │  2. Open PR           │                        │                        │                        │
    │  feature → develop    │                        │                        │                        │
    ├──────────────────────▶│                        │                        │                        │
    │                       │  3. Trigger CI         │                        │                        │
    │                       ├───────────────────────▶│                        │                        │
    │                       │                        │                        │                        │
    │                       │  4. Lint + Test + Build│                        │                        │
    │                       │     (green ✅)         │                        │                        │
    │                       │◀───────────────────────│                        │                        │
    │                       │                        │                        │                        │
    │  5. Merge PR          │                        │                        │                        │
    │  develop              │                        │                        │                        │
    ├──────────────────────▶│                        │                        │                        │
    │                       │  6. Trigger CI + Deploy│                        │                        │
    │                       ├───────────────────────▶│                        │                        │
    │                       │                        │  7. Build + Deploy     │                        │
    │                       │                        ├───────────────────────▶│                        │
    │                       │                        │  8. Health check ✅    │                        │
    │                       │                        │◀───────────────────────│                        │
    │                       │◀───────────────────────│                        │                        │
    │                       │                        │                        │                        │
    │  9. Testa no staging  │                        │                        │                        │
    │  app.stg.bigbase.click│                        │                        │                        │
    │─────────────────────────────────────────────────────────────────────────▶│                        │
    │                       │                        │                        │                        │
    │  10. Open PR          │                        │                        │                        │
    │  develop → main       │                        │                        │                        │
    ├──────────────────────▶│                        │                        │                        │
    │                       │  11. Trigger CI        │                        │                        │
    │                       ├───────────────────────▶│                        │                        │
    │                       │  12. Lint + Test ✅    │                        │                        │
    │                       │◀───────────────────────│                        │                        │
    │                       │                        │                        │                        │
    │  13. Merge PR         │                        │                        │                        │
    │  main                 │                        │                        │                        │
    ├──────────────────────▶│                        │                        │                        │
    │                       │  14. Trigger Deploy Prod                       │                        │
    │                       ├────────────────────────────────────────────────────────────────────────▶│
    │                       │                        │                        │  15. Build + Deploy    │
    │                       │                        │                        │◀───────────────────────│
    │                       │                        │                        │  16. Health check ✅   │
    │                       │                        │                        ├───────────────────────▶│
    │                       │◀───────────────────────────────────────────────────────────────────────│
    │                       │                        │                        │                        │
    │  17. ✅ LIVE          │                        │                        │                        │
    │  app.bigbase.click    │                        │                        │                        │
    │◀───────────────────────────────────────────────────────────────────────────────────────────────│
```

### Resumo dos 5 estágios

| Estágio | Branch | Ação | Destino | Trigger |
|---------|--------|------|---------|---------|
| **1. Push** | `feature/*` | `git push` | Forgejo | Manual |
| **2. PR Review** | `feature/* → develop` | CI (lint+test+build) | Forgejo | Auto |
| **3. Staging** | `develop` | Deploy automático | VPS-B (BigBase Stg) | Auto (merge) |
| **4. Validação** | — | Teste manual no staging | `*.stg.bigbase.click` | Manual |
| **5. Produção** | `main` | Deploy automático | VPS-A (BigBase Prod) | Auto (merge) |

---

## 4. Forgejo Actions — CI/CD Compatibility

### O que muda do GitHub Actions?

**Quase nada.** Forgejo Actions aceita ~95% do YAML do GitHub Actions. As diferenças:

| Feature | GitHub Actions | Forgejo Actions |
|---------|---------------|-----------------|
| Runner hosted | `ubuntu-latest` | Self-hosted runner no VPS-B |
| Marketplace actions | `uses: actions/checkout@v7` | ✅ Funciona (clona do GitHub) |
| Secrets | GitHub UI | Forgejo Settings → Secrets |
| Environments | GitHub UI | Forgejo Settings → Environments |
| Artifacts | GitHub storage | Forgejo local storage |
| Cache | GitHub cache | Runner local cache |

### Workflow YAML — Quase idêntico ao GitHub

```yaml
# .forgejo/workflows/ci-cd.yml  (ou .github/workflows/ci-cd.yml — ambos funcionam)
name: CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

concurrency:
  group: pipeline-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  ci:
    runs-on: self-hosted  # ← runner no VPS-B
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v7

      - uses: actions/setup-node@v6
        with:
          node-version: 22
          cache: npm

      - run: npm ci
      - run: npm run lint --if-present
      - run: npm run typecheck --if-present
      - run: npm test --if-present
      - run: npm run build --if-present

  deploy-staging:
    if: github.ref == 'refs/heads/develop'
    needs: [ci]
    runs-on: self-hosted
    environment: staging
    steps:
      - uses: actions/checkout@v7

      - name: Deploy to Staging BigBase
        run: |
          curl -sfX POST "${{ secrets.BIGBASE_STAGING_URL }}/api/sites/${{ secrets.SITE_ID }}/deploy" \
            -H "Authorization: Bearer ${{ secrets.BIGBASE_STAGING_TOKEN }}" \
            -H "Content-Type: application/json" \
            -d '{"branch":"develop","app_type":"node"}'

      - name: Health check
        run: |
          for i in $(seq 1 8); do
            STATUS=$(curl -s -o /dev/null -w '%{http_code}' "${{ secrets.SITE_URL }}")
            if [ "$STATUS" = "200" ]; then
              echo "✅ Staging LIVE"
              exit 0
            fi
            echo "Attempt $i/8: HTTP $STATUS"
            sleep 10
          done
          exit 1

  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: [ci]
    runs-on: self-hosted
    environment: production  # ← requer approval no Forgejo
    steps:
      - uses: actions/checkout@v7

      - name: Deploy to Production BigBase
        run: |
          curl -sfX POST "${{ secrets.BIGBASE_PROD_URL }}/api/sites/${{ secrets.SITE_ID }}/deploy" \
            -H "Authorization: Bearer ${{ secrets.BIGBASE_PROD_TOKEN }}" \
            -H "Content-Type: application/json" \
            -d '{"branch":"main","app_type":"node"}'

      - name: Health check
        run: |
          for i in $(seq 1 12); do
            STATUS=$(curl -s -o /dev/null -w '%{http_code}' "${{ secrets.SITE_URL }}")
            if [ "$STATUS" = "200" ]; then
              echo "✅ Production LIVE"
              exit 0
            fi
            echo "Attempt $i/12: HTTP $STATUS"
            sleep 10
          done
          exit 1
```

### O que NÃO funciona (o 5%)

| Incompatível | Alternativa |
|-------------|-------------|
| `github.com` hardcoded em some actions | Substituir por URL do Forgejo |
| GitHub-specific API calls (`api.github.com`) | Usar API do Forgejo (`git.bigbase.click/api/v1`) |
| `runs-on: ubuntu-latest` (hosted runner) | `runs-on: self-hosted` |
| GitHub Container Registry | Usar registry local ou Docker Hub |
| GitHub Packages | Forgejo Packages ou npm registry próprio |

---

## 5. Setup do Forgejo — Quick Start

### Docker Compose (recomendado)

```yaml
# /opt/forgejo/docker-compose.yml
version: '3'

services:
  forgejo:
    image: codeberg.org/forgejo/forgejo:10
    container_name: forgejo
    restart: always
    environment:
      - USER_UID=1000
      - USER_GID=1000
      - FORGEJO__database__DB_TYPE=sqlite3
      - FORGEJO__server__DOMAIN=git.bigbase.click
      - FORGEJO__server__ROOT_URL=https://git.bigbase.click/
      - FORGEJO__server__SSH_DOMAIN=git.bigbase.click
    volumes:
      - /opt/forgejo/data:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
    ports:
      - "3000:3000"   # Web UI
      - "2222:22"     # SSH
    networks:
      - forgejo

networks:
  forgejo:
    driver: bridge
```

### Caddy Reverse Proxy (HTTPS automático)

```
# /etc/caddy/Caddyfile
git.bigbase.click {
    reverse_proxy localhost:3000
}

stg.bigbase.click {
    reverse_proxy localhost:8080  # BigBase staging
}

*.stg.bigbase.click {
    reverse_proxy localhost:8080
}

bigbase.click {
    reverse_proxy localhost:8081  # (se BigBase prod estiver neste server)
}

*.bigbase.click {
    reverse_proxy localhost:8081
}
```

### Forgejo Actions Runner — Setup

```bash
# 1. Registrar runner no Forgejo
# Settings → Actions → Runners → Create Runner

# 2. Instalar runner
curl -L -o forgejo-runner https://codeberg.org/forgejo/runner/releases/download/v6/forgejo-runner-linux-amd64
chmod +x forgejo-runner
sudo mv forgejo-runner /usr/local/bin/

# 3. Configurar
forgejo-runner generate-config > .runner/config.yaml
# Editar config.yaml com token do passo 1

# 4. Executar como serviço
sudo tee /etc/systemd/system/forgejo-runner.service << 'EOF'
[Unit]
Description=Forgejo Actions Runner
After=network.target

[Service]
Type=simple
User=runner
WorkingDirectory=/opt/runner
ExecStart=/usr/local/bin/forgejo-runner daemon --config /opt/runner/config.yaml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable forgejo-runner
sudo systemctl start forgejo-runner
```

---

## 6. Migração GitHub → Forgejo

### Script de Migração em Massa

```bash
#!/bin/bash
# scripts/migrate-github-to-forgejo.sh
# Migra todos os 58 repos do GitHub para Forgejo

FORGEJO_URL="https://git.bigbase.click"
FORGEJO_TOKEN="your-forgejo-api-token"
GITHUB_ORG="danielvm-git"

# Listar todos os repos do GitHub
REPOS=$(gh repo list "$GITHUB_ORG" --limit 100 --json name -q '.[].name')

for repo in $REPOS; do
  echo "Migrating $repo..."

  # Criar repo no Forgejo via API
  curl -sX POST "$FORGEJO_URL/api/v1/user/repos" \
    -H "Authorization: token $FORGEJO_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"$repo\",
      \"private\": true,
      \"auto_init\": false
    }"

  # Mirror do GitHub para Forgejo
  cd "/tmp/$repo" || { gh repo clone "$GITHUB_ORG/$repo" "/tmp/$repo"; cd "/tmp/$repo"; }

  git remote add forgejo "https://git.bigbase.click/danielvm/$repo.git" 2>/dev/null
  git push forgejo --all
  git push forgejo --tags

  echo "✅ $repo migrated"
  cd -
done

echo "🎉 All repos migrated to Forgejo!"
```

### Migração de Secrets

```bash
#!/bin/bash
# scripts/migrate-secrets.sh
# Copia secrets do GitHub para Forgejo

FORGEJO_URL="https://git.bigbase.click"
FORGEJO_TOKEN="your-forgejo-api-token"
GITHUB_ORG="danielvm-git"

REPOS=$(gh repo list "$GITHUB_ORG" --limit 100 --json name -q '.[].name')

for repo in $REPOS; do
  echo "Migrating secrets for $repo..."

  # Listar secrets do GitHub
  SECRETS=$(gh secret list -R "$GITHUB_ORG/$repo" --json name -q '.[].name')

  for secret in $SECRETS; do
    VALUE=$(gh secret view "$secret" -R "$GITHUB_ORG/$repo" --json value -q '.value')

    # Criar secret no Forgejo
    curl -sX PUT "$FORGEJO_URL/api/v1/repos/danielvm/$repo/actions/secrets/$secret" \
      -H "Authorization: token $FORGEJO_TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"data\":\"$VALUE\"}"

    echo "  ✅ Secret $secret migrated"
  done
done
```

---

## 7. DNS — Estrutura Completa

```
# Registros DNS (Cloudflare / registrar)

# Git hosting
git.bigbase.click          A       <VPS-B IP>        # Forgejo

# Staging (VPS-B)
stg.bigbase.click          A       <VPS-B IP>        # BigBase staging
*.stg.bigbase.click        A       <VPS-B IP>        # Wildcard staging apps

# Produção (VPS-A)
bigbase.click              A       <VPS-A IP>        # BigBase production
*.bigbase.click            A       <VPS-A IP>        # Wildcard prod apps

# Exemplos de apps
bolao.bigbase.click        CNAME   bigbase.click     # App 1 prod
bolao.stg.bigbase.click    CNAME   stg.bigbase.click # App 1 staging
library.bigbase.click      CNAME   bigbase.click     # App 2 prod
library.stg.bigbase.click  CNAME   stg.bigbase.click # App 2 staging
```

---

## 8. Segurança — Hardening

### VPS-B (Forgejo + Staging)

```bash
# Firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp      # HTTP
ufw allow 443/tcp     # HTTPS
ufw allow 2222/tcp    # Forgejo SSH (se exposto)
ufw enable

# Forgejo security
# Settings → Authentication → Disable self-registration
# Settings → Repository → Default private
# Settings → Security → Enforce 2FA
```

### VPS-A (Produção)

```bash
# Firewall — mais restritivo
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable

# NÃO expor portas de database
# NÃO expor portas de admin do BigBase
```

### SSH Key-only Auth (ambos)

```bash
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
```

---

## 9. Backup Strategy

### Forgejo Backup (VPS-B)

```bash
#!/bin/bash
# /opt/forgejo/scripts/backup.sh — cron: 0 3 * * *

BACKUP_DIR="/opt/forgejo/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Forgejo dump
docker exec forgejo forgejo dump -c /data/gitea/app.ini -f "/data/backups/forgejo-$DATE.zip"

# Sync to offsite (Backblaze B2, S3, etc.)
rclone sync "$BACKUP_DIR" "remote:forgejo-backups/" --max-age 7d

# Cleanup old backups (keep 7 days)
find "$BACKUP_DIR" -name "*.zip" -mtime +7 -delete

echo "✅ Forgejo backup completed: $DATE"
```

### BigBase Backup (ambos VPS)

```bash
#!/bin/bash
# /opt/bigbase/scripts/backup.sh — cron: 0 4 * * *

# BigBase data directory
tar -czf "/backups/bigbase-$(date +%Y%m%d).tar.gz" /opt/bigbase/data/

# Database dump (se PostgreSQL)
pg_dump bigbase > "/backups/bigbase-db-$(date +%Y%m%d).sql"

# Sync offsite
rclone sync /backups/ "remote:bigbase-backups/"
```

---

## 10. Monitoring — Stack Completo

```
┌─────────────────────────────────────────────────────────────────┐
│                    Monitoring Dashboard                          │
│                    monitor.bigbase.click (VPS-A)                │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐            │
│  │  BigBase    │  │  Forgejo    │  │  VPS Health │            │
│  │  Monitoring │  │  Health     │  │  (CPU/RAM)  │            │
│  │  (apps)     │  │  (Git)      │  │             │            │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘            │
│         │                │                │                    │
│         ▼                ▼                ▼                    │
│  ┌─────────────────────────────────────────────────┐          │
│  │              Alert Channel                       │          │
│  │  Telegram / Email / Webhook                      │          │
│  └─────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

### Uptime Kuma (recomendado)

```bash
# No VPS-A (produção) ou VPS separado
docker run -d --restart=always \
  -p 3001:3001 \
  -v uptime-kuma:/app/data \
  --name uptime-kuma \
  louislam/uptime-kuma

# Monitores a configurar:
# - git.bigbase.click (Forgejo)
# - stg.bigbase.click (Staging)
# - bigbase.click (Produção)
# - Cada app individual (*.bigbase.click)
```

---

## 11. Custos — Comparativo

### Self-Hosted (recomendado)

| Item | Custo mensal |
|------|-------------|
| VPS-A (Contabo 16GB/6c) | ~$12-15 |
| VPS-B (Contabo 12GB/4c) | ~$8-10 |
| BigBase (self-hosted) | $0 |
| Forgejo (self-hosted) | $0 |
| DNS (Cloudflare) | $0 |
| **Total** | **~$20-25/mês** |

### GitHub (para comparação)

| Item | Custo mensal |
|------|-------------|
| GitHub Team (58 repos, 5 users) | ~$20/mês |
| GitHub Actions (extra minutes) | ~$10-20/mês |
| VPS-A (produção) | ~$12-15 |
| VPS-B (staging) | ~$8-10 |
| **Total** | **~$50-65/mês** |

**Economia: ~$30-40/mês** com self-hosted, além de controle total dos dados.

---

## 12. Comparativo — 3 Opções de Arquitetura

### Opção A: GitHub + BigBase (anterior)

```
GitHub (cloud) → GitHub Actions → VPS-B (staging) + VPS-A (prod)
```

- ✅ Sem manutenção de Git server
- ✅ GitHub Actions managed
- ❌ Vendor lock-in (Microsoft)
- ❌ $50-65/mês
- ❌ Dados nos EUA

### Opção B: Forgejo + BigBase (recomendado) ✅

```
Forgejo (VPS-B) → Forgejo Actions → VPS-B (staging) + VPS-A (prod)
```

- ✅ Controle total
- ✅ $20-25/mês
- ✅ Dados no Brasil/seu VPS
- ✅ CI/CD ilimitado
- ⚠️ Manutenção do Git server (mas mínimo com Forgejo)

### Opção C: Forgejo + GitHub Mirror (híbrido)

```
Forgejo (VPS-B, source of truth) → mirror → GitHub (backup/visibility)
```

- ✅ Código no seu servidor
- ✅ GitHub como backup público
- ✅ Pode usar GitHub Actions para OSS
- ⚠️ Sync manual ou automático (webhook)

---

## 13. Implementação — Plano em 4 Fases

### Fase 1: Fundação (1-2 dias)

```bash
# VPS-B
□ Instalar Docker + Docker Compose
□ Subir Forgejo (docker-compose up)
□ Configurar Caddy reverse proxy
□ Configurar DNS (git.bigbase.click → VPS-B IP)
□ Criar usuários e organizações no Forgejo
□ Instalar Forgejo Actions Runner
□ Subir BigBase staging

# VPS-A
□ Configurar BigBase production
□ Configurar DNS (*.bigbase.click → VPS-A IP)
□ Configurar monitoring
```

### Fase 2: Migração (2-3 dias)

```bash
□ Migrar 58 repos do GitHub para Forgejo
□ Migrar secrets por repo
□ Testar CI/CD com 1 repo piloto
□ Validar staging deploy
□ Validar production deploy
```

### Fase 3: Rollout (1 semana)

```bash
□ Classificar repos por categoria
□ Configurar workflows em lotes (10 por vez)
□ Treinar equipe no novo fluxo
□ Documentar runbooks
```

### Fase 4: Hardening (contínuo)

```bash
□ Backup automation (Forgejo + BigBase)
□ Monitoring + alerting
□ Security patches (unattended-upgrades)
□ Disaster recovery drill (quarterly)
```

---

## 14. FAQ

### P: O Forgejo Actions Runner consome muita RAM?

**R:** ~500MB-1GB por job CI. Com 12GB no VPS-B, dá para rodar 2-3 jobs simultâneos sem impactar o staging. Para jobs pesados (build de Docker images), considere um runner dedicado no VPS-A.

### P: Posso usar GitHub Actions YAML existente?

**R:** Sim, 95% funciona sem alteração. Mude `runs-on: ubuntu-latest` para `runs-on: self-hosted` e ajuste actions que hardcodeiam `api.github.com`.

### P: E se o VPS-B cair? Perco o Git?

**R:** Por isso o backup offsite (B2/S3). Com `forgejo dump` diário + rclone, o restore completo leva ~18 minutos. Para zero-downtime, considere mirror para GitHub como backup.

### P: Posso ter repos públicos no Forgejo?

**R:** Sim. Forgejo suporta repos públicos, stars, forks — tudo como GitHub. Para projetos open source, exponha na web.

### P: Preciso de PostgreSQL ou SQLite basta?

**R:** SQLite até ~50 usuários ativos / 200 repos. Com 58 repos, SQLite é suficiente. Migre para PostgreSQL se sentir lock contention.

### P: Como funciona o approval para deploy em produção?

**R:** Forgejo suporta "Environments" com required reviewers. Configure o environment `production` para exigir approval manual antes do deploy.
