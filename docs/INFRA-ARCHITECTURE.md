# 🏗️ Infraestrutura — Ecossistema danielvm-git

> Arquitetura de infra para 58 repositórios com ambientes local → staging → produção.

## Visão Geral

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              GITHUB (danielvm-git)                              │
│                                                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       ┌──────────┐                   │
│  │  repo 1  │  │  repo 2  │  │  repo 3  │  ...  │  repo 58 │                   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘       └────┬─────┘                   │
│       │              │              │                  │                         │
│       └──────────────┴──────┬───────┴──────────────────┘                         │
│                             │                                                    │
│                    ┌────────▼────────┐                                           │
│                    │  .github org    │                                           │
│                    │  (templates)    │                                           │
│                    └────────┬────────┘                                           │
│                             │                                                    │
│              ┌──────────────┼──────────────┐                                    │
│              ▼              ▼              ▼                                     │
│     CI on PR/push    Deploy staging  Deploy prod                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
         │                  │                  │
         │           ┌──────▼──────┐    ┌──────▼──────┐
         │           │   VPS-B     │    │   VPS-A     │
         │           │  12GB/4c    │    │  16GB/6c    │
         │           │             │    │             │
         │           │  BigBase    │    │  BigBase    │
         │           │  Staging    │    │  Production │
         │           │             │    │             │
         │           │ • app1.stg  │    │ • app1      │
         │           │ • app2.stg  │    │ • app2      │
         │           │ • app3.stg  │    │ • app3      │
         │           └─────────────┘    └─────────────┘
         │
    ┌────▼────┐
    │  Local  │
    │   Dev   │
    │ (Macs)  │
    └─────────┘
```

---

## 1. Servidores — Distribuição de Carga

### Por que separar staging e produção em máquinas diferentes?

| Critério | Staging na VPS-B (12GB/4c) | Produção na VPS-A (16GB/6c) |
|----------|---------------------------|----------------------------|
| **Isolamento** | Staging não compete com prod por CPU/RAM | Recursos dedicados ao tráfego real |
| **Segurança** | Deploy de branches `develop` pode quebrar | Branch `main` só após CI + staging verde |
| **Custo** | VPS menor para carga menor (devs internos) | VPS maior para tráfego real |
| **Debugging** | Pode reiniciar sem impacto | Zero downtime garantido |

### Mapa de Serviços por Máquina

```
┌─────────────────────────────────────────────────────────────┐
│                    VPS-A (Produção) — 16GB / 6 cores        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  BigBase Production Instance                        │    │
│  │                                                     │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐            │    │
│  │  │  deploy  │ │   auth   │ │    db    │            │    │
│  │  │ (webapps)│ │(login/JWT)│ │(SQLite/PG)│           │    │
│  │  └──────────┘ └──────────┘ └──────────┘            │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐            │    │
│  │  │ storage  │ │functions │ │ realtime │            │    │
│  │  │ (files)  │ │ (serverl)│ │ (WebSocket)│           │    │
│  │  └──────────┘ └──────────┘ └──────────┘            │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐            │    │
│  │  │monitoring│ │ webhooks │ │messaging │            │    │
│  │  │(alerts)  │ │ (events) │ │(email/SMS)│           │    │
│  │  └──────────┘ └──────────┘ └──────────┘            │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  RAM allocation (~16GB):                                    │
│  • BigBase core: 2GB                                        │
│  • Web apps (N × instances): 8GB                            │
│  • Database: 2GB                                            │
│  • OS + monitoring: 2GB                                     │
│  • Buffer: 2GB                                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    VPS-B (Staging) — 12GB / 4 cores         │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  BigBase Staging Instance                           │    │
│  │                                                     │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐            │    │
│  │  │  deploy  │ │   auth   │ │    db    │            │    │
│  │  │(staging) │ │(shared)  │ │ (mirror) │            │    │
│  │  └──────────┘ └──────────┘ └──────────┘            │    │
│  │  ┌──────────┐ ┌──────────┐                         │    │
│  │  │monitoring│ │functions │                         │    │
│  │  │ (basic)  │ │(limited) │                         │    │
│  │  └──────────┘ └──────────┘                         │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
│  RAM allocation (~12GB):                                    │
│  • BigBase core: 1.5GB                                      │
│  • Web apps (N × instances): 6GB                            │
│  • Database: 1.5GB                                          │
│  • OS: 1.5GB                                                │
│  • Buffer: 1.5GB                                            │
└─────────────────────────────────────────────────────────────┘
```

### Serviços Desativados no Staging (economizar RAM)

No staging, desative serviços não essenciais:
- **messaging** — não precisa enviar emails/SMS reais em staging
- **realtime** — reduz WebSocket overhead
- **webhooks** — staging não dispara eventos para prod

---

## 2. Ambientes — Definição e Propósito

### Três Ambientes

| Ambiente | Branch | Server | URL pattern | Deploy trigger | Público |
|----------|--------|--------|-------------|----------------|---------|
| **Local** | feature/* | Mac dev | `localhost:PORT` | manual | Não |
| **Staging** | `develop` | VPS-B | `app.stg.bigbase.click` | auto (push) | Interno |
| **Produção** | `main` | VPS-A | `app.bigbase.click` | auto (push) | Público |

### Fluxo de Código

```
feature/my-branch  ──PR──▶  develop  ──PR──▶  main
     │                         │                │
     │                    auto deploy       auto deploy
     │                    to staging        to production
     │                         │                │
   [CI only]            [CI + staging]    [CI + prod]
```

---

## 3. GitHub Actions — Pipeline de CI/CD

### Estrutura de Secrets por Environment

O GitHub suporta **Environments** com proteção por branch. Configure:

```
GitHub → Settings → Environments:

┌─────────────────────────────────────────────────────┐
│ Environment: "production"                           │
│ • Required reviewers: [danielvm]                    │
│ • Wait timer: 5 minutes                             │
│ • Deployment branches: main only                    │
│                                                     │
│ Secrets:                                            │
│   BIGBASE_PROD_SERVER   = https://bigbase.click     │
│   BIGBASE_PROD_TOKEN    = bb_prod_xxxx              │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Environment: "staging"                              │
│ • No required reviewers (auto-deploy)               │
│ • Deployment branches: develop only                 │
│                                                     │
│ Secrets:                                            │
│   BIGBASE_STAGING_SERVER = https://staging.bigbase.click │
│   BIGBASE_STAGING_TOKEN  = bb_stg_xxxx             │
└─────────────────────────────────────────────────────┘
```

### Workflow Template — Multi-Environment

O template `ci-cd-node.yml` atual já deploya para BigBase. Vamos estendê-lo para suportar staging + prod:

```yaml
# .github/workflow-templates/ci-cd-node-multienv.yml
name: CI/CD (Multi-Env)

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

permissions:
  contents: read

concurrency:
  group: pipeline-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  APP_TYPE: static  # Override per repo

jobs:
  # ──────────────────────────────────────────
  # CI — roda em TODOS os pushes e PRs
  # ──────────────────────────────────────────
  ci:
    runs-on: ubuntu-22.04
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

  # ──────────────────────────────────────────
  # Verify — Conventional Commits + no AI attribution
  # ──────────────────────────────────────────
  verify:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-22.04
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v7
        with:
          fetch-depth: 0
      - name: Check Conventional Commits
        run: |
          git log origin/${{ github.base_ref }}..HEAD --oneline | while read -r line; do
            if ! echo "$line" | grep -qE "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?: "; then
              echo "FAIL: Non-conventional commit: $line"
              exit 1
            fi
          done
      - name: Check no AI attribution
        run: |
          if git log origin/${{ github.base_ref }}..HEAD --format="%B" | grep -qiE '^co[- ]authored[- ]by:'; then
            echo "FAIL: Co-authored-by footer blocked"
            exit 1
          fi

  # ──────────────────────────────────────────
  # Deploy Staging — auto no push para develop
  # ──────────────────────────────────────────
  deploy-staging:
    if: github.ref == 'refs/heads/develop' && github.event_name == 'push'
    needs: [ci]
    runs-on: ubuntu-22.04
    timeout-minutes: 10
    environment: staging
    steps:
      - uses: actions/checkout@v7
      - name: Deploy to Staging BigBase
        uses: danielvm-git/.github/actions/bigbase-deploy@main
        with:
          site_id: ${{ secrets.BIGBASE_SITE_ID }}
          app_type: ${{ env.APP_TYPE }}
          site_url: ${{ secrets.SITE_URL }}
          deploy_token: ${{ secrets.BIGBASE_DEPLOY_TOKEN }}
          bigbase_server: ${{ secrets.BIGBASE_STAGING_SERVER }}

  # ──────────────────────────────────────────
  # Deploy Production — auto no push para main
  # ──────────────────────────────────────────
  deploy-production:
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    needs: [ci, verify]
    runs-on: ubuntu-22.04
    timeout-minutes: 10
    environment: production
    steps:
      - uses: actions/checkout@v7
      - name: Deploy to Production BigBase
        uses: danielvm-git/.github/actions/bigbase-deploy@main
        with:
          site_id: ${{ secrets.BIGBASE_SITE_ID }}
          app_type: ${{ env.APP_TYPE }}
          site_url: ${{ secrets.SITE_URL }}
          deploy_token: ${{ secrets.BIGBASE_DEPLOY_TOKEN }}
          bigbase_server: ${{ secrets.BIGBASE_PROD_SERVER }}
```

---

## 4. Estrutura de Repositórios

### Para os 58 repositórios

Cada repo herda os templates do `.github` org:

```
my-web-app/
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # Copia do template, com valores específicos
├── src/
├── package.json
└── AGENTS.md                  # Contexto do agente para este repo
```

O workflow de cada repo é uma **instância** do template:

```yaml
# my-web-app/.github/workflows/ci-cd.yml
name: CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

permissions:
  contents: read

concurrency:
  group: pipeline-${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

env:
  APP_TYPE: node  # Específico deste repo

jobs:
  ci:
    uses: danielvm-git/.github/.github/workflows/ci-cd-node-multienv.yml@main
    secrets: inherit

  deploy-staging:
    needs: ci
    if: github.ref == 'refs/heads/develop'
    uses: danielvm-git/.github/.github/workflows/ci-cd-node-multienv.yml@main
    secrets: inherit

  deploy-production:
    needs: ci
    if: github.ref == 'refs/heads/main'
    uses: danielvm-git/.github/.github/workflows/ci-cd-node-multienv.yml@main
    secrets: inherit
```

### Reusable Workflows (o caminho correto)

Em vez de copiar templates, use **GitHub Reusable Workflows**:

```yaml
# No repo filho (my-web-app):
jobs:
  ci:
    uses: danielvm-git/.github/.github/workflows/ci-shared.yml@main
```

```yaml
# No .github org (.github/workflows/ci-shared.yml):
name: Shared CI
on:
  workflow_call:
    inputs:
      app_type:
        type: string
        default: node
    secrets:
      BIGBASE_DEPLOY_TOKEN:
        required: true

jobs:
  ci:
    runs-on: ubuntu-22.04
    steps:
      # ... shared steps
```

---

## 5. Gerenciamento de 58 Repos — Estratégia Escalável

### Classifique seus repos em categorias

| Categoria | Qtd estimada | Template | Deploy target |
|-----------|-------------|----------|---------------|
| **Web Apps (SPA/SSR)** | ~15 | `ci-cd-node` | BigBase deploy |
| **Static Sites** | ~20 | `ci-cd-static` | BigBase deploy |
| **APIs (Python)** | ~10 | `ci-cd-python` | BigBase deploy |
| **Docs/MkDocs** | ~8 | `ci-cd-pages-mkdocs` | GitHub Pages |
| **Docs/Starlight** | ~5 | `ci-cd-pages-starlight` | GitHub Pages |

### Registry de Sites — `sites.yaml`

Para rastrear qual repo deploya para qual URL:

```yaml
# .github/sites.yaml
sites:
  - repo: big-bolao
    app_type: node
    prod_url: https://bolao.bigbase.click
    staging_url: https://bolao.stg.bigbase.click
    prod_site_id: site_abc123
    staging_site_id: site_def456

  - repo: big-library
    app_type: static
    prod_url: https://library.bigbase.click
    staging_url: https://library.stg.bigbase.click
    prod_site_id: site_ghi789
    staging_site_id: site_jkl012

  # ... mais 56 repos
```

### Script de Bootstrap — Setup de 58 repos de uma vez

```bash
#!/bin/bash
# scripts/bootstrap-all-repos.sh

while IFS= read -r repo; do
  echo "Setting up $repo..."
  gh repo clone "danielvm-git/$repo" "/tmp/$repo" -- --depth=1

  # Copiar workflow template
  cp workflow-templates/ci-cd-node.yml "/tmp/$repo/.github/workflows/ci-cd.yml"

  # Substituir placeholders
  sed -i '' "s/CHANGE-ME/${repo}/g" "/tmp/$repo/.github/workflows/ci-cd.yml"

  # Commit e push
  cd "/tmp/$repo"
  git checkout -b chore/ci-setup
  git add .github/workflows/
  git commit -m "ci: add multi-environment CI/CD workflow"
  git push -u origin chore/ci-setup
  gh pr create --title "ci: setup CI/CD" --body "Automated CI/CD setup"

  cd -
done < repos.txt
```

---

## 6. Fluxo Completo — Feature to Production

### Diagrama de Sequência

```
 Developer         GitHub           CI Runner        VPS-B (Stg)      VPS-A (Prod)
    │                │                │                │                │
    │  git push      │                │                │                │
    │  feature/xxx   │                │                │                │
    ├───────────────▶│                │                │                │
    │                │  trigger CI    │                │                │
    │                ├───────────────▶│                │                │
    │                │                │                │                │
    │                │  lint/test/build│               │                │
    │                │  (green ✅)    │                │                │
    │                │◀───────────────│                │                │
    │                │                │                │                │
    │  open PR       │                │                │                │
    │  to develop    │                │                │                │
    ├───────────────▶│                │                │                │
    │                │  verify CC     │                │                │
    │                ├───────────────▶│                │                │
    │                │  (pass ✅)     │                │                │
    │                │◀───────────────│                │                │
    │                │                │                │                │
    │  merge PR      │                │                │                │
    │  to develop    │                │                │                │
    ├───────────────▶│                │                │                │
    │                │  deploy-staging│                │                │
    │                ├───────────────▶│                │                │
    │                │                │  deploy to BB  │                │
    │                │                ├───────────────▶│                │
    │                │                │  health check  │                │
    │                │                │◀───────────────│                │
    │                │◀───────────────│                │                │
    │                │                │                │                │
    │  [testa no staging]            │                │                │
    │                │                │                │                │
    │  open PR       │                │                │                │
    │  develop→main  │                │                │                │
    ├───────────────▶│                │                │                │
    │                │  CI + verify   │                │                │
    │                ├───────────────▶│                │                │
    │                │  (green ✅)    │                │                │
    │                │◀───────────────│                │                │
    │                │                │                │                │
    │  merge PR      │                │                │                │
    │  to main       │                │                │                │
    ├───────────────▶│                │                │                │
    │                │  deploy-prod   │                │                │
    │                ├───────────────▶│                │                │
    │                │                │  deploy to BB  │                │
    │                │                ├─────────────────────────────────▶│
    │                │                │  health check  │                │
    │                │                │◀─────────────────────────────────│
    │                │◀───────────────│                │                │
    │                │                │                │                │
    │  ✅ LIVE       │                │                │                │
    │◀───────────────│                │                │                │
```

---

## 7. GitHub Environments — Proteção por Branch

### Configuração Recomendada

```yaml
# GitHub Settings → Environments

production:
  protection:
    required_reviewers: [danielvm]
    wait_timer: 5  # minutos — tempo para cancelar deploy acidental
    branch_policy:
      allowed_branches: [main]
  secrets:
    BIGBASE_PROD_SERVER: https://bigbase.click
    BIGBASE_PROD_TOKEN: bb_prod_xxxx
    SITE_URL: https://myapp.bigbase.click
    BIGBASE_SITE_ID: site_xxxx

staging:
  protection:
    required_reviewers: []  # auto-deploy
    branch_policy:
      allowed_branches: [develop]
  secrets:
    BIGBASE_STAGING_SERVER: https://stg.bigbase.click
    BIGBASE_STAGING_TOKEN: bb_stg_xxxx
    SITE_URL: https://myapp.stg.bigbase.click
    BIGBASE_SITE_ID: site_yyyy
```

---

## 8. Database — Staging vs Produção

### Estratégia de Dados

```
┌─────────────────────────────────────────────────────────────┐
│                    VPS-A (Produção)                          │
│                                                             │
│  ┌─────────────────────────────────────────────┐            │
│  │  SQLite / PostgreSQL                        │            │
│  │  Dados reais de produção                    │            │
│  │  Backups diários → /backups/prod/           │            │
│  └─────────────────────────────────────────────┘            │
│                                                             │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    VPS-B (Staging)                          │
│                                                             │
│  ┌─────────────────────────────────────────────┐            │
│  │  SQLite / PostgreSQL                        │            │
│  │  Dados de teste (seed)                      │            │
│  │  Backup semanal (opcional)                  │            │
│  └─────────────────────────────────────────────┘            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Seed de dados para staging

```bash
# scripts/seed-staging.sh — executa no deploy para staging
#!/bin/bash
echo "Seeding staging database..."

# Importar fixtures de teste
psql $DATABASE_URL < fixtures/seed.sql

# Ou via API
curl -X POST "$STAGING_URL/api/seed" \
  -H "Authorization: Bearer $SEED_TOKEN"
```

---

## 9. DNS — Estrutura de Subdomínios

```
bigbase.click                  → VPS-A (BigBase production)
*.bigbase.click                → VPS-A (wildcard para apps)

stg.bigbase.click              → VPS-B (BigBase staging)
*.stg.bigbase.click            → VPS-B (wildcard para staging)

app1.bigbase.click             → VPS-A (app 1 prod)
app1.stg.bigbase.click         → VPS-B (app 1 staging)

app2.bigbase.click             → VPS-A (app 2 prod)
app2.stg.bigbase.click         → VPS-B (app 2 staging)

monitoring.bigbase.click       → VPS-A (monitoring dashboard)
```

---

## 10. Monitoring & Alerting

### Camada de Monitoramento

```
┌─────────────────────────────────────────────────────────────┐
│  BigBase Monitoring Service (VPS-A)                         │
│                                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                    │
│  │ Health   │ │  Metrics │ │  Alerts  │                    │
│  │ Checks   │ │ (CPU/RAM)│ │ (webhook)│                    │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘                    │
│       │              │              │                        │
│       ▼              ▼              ▼                        │
│  ┌─────────────────────────────────────────┐                │
│  │  monitoring.bigbase.click               │                │
│  │  Dashboard — status de todos os apps    │                │
│  └─────────────────────────────────────────┘                │
│       │                                                     │
│       ▼                                                     │
│  Telegram / Email / Webhook quando app cair                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 11. Segurança — Checklist

### VPS Hardening

```bash
# Em AMBAS as VPS:

# 1. Firewall (UFW)
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw enable

# 2. Fail2ban
apt install fail2ban
systemctl enable fail2ban

# 3. SSH key-only auth
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# 4. Unattended upgrades
apt install unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

### GitHub Secrets — Onde configurar

| Secret | Scope | Valor |
|--------|-------|-------|
| `BIGBASE_PROD_TOKEN` | Environment: production | Token scoped da VPS-A |
| `BIGBASE_STAGING_TOKEN` | Environment: staging | Token scoped da VPS-B |
| `BIGBASE_SITE_ID` | Per-repo | ID do site no BigBase |
| `SITE_URL` | Per-repo | URL do app para health check |

---

## 12. Custos Estimados

| Item | Custo mensal |
|------|-------------|
| VPS-A (Contabo 16GB/6c) | ~$12-15 |
| VPS-B (Contabo 12GB/4c) | ~$8-10 |
| GitHub Actions (free tier) | $0 (2000 min/mês) |
| BigBase (self-hosted) | $0 |
| DNS (Cloudflare) | $0 |
| **Total** | **~$20-25/mês** |

---

## 13. Próximos Passos — Implementação

### Ordem de execução

```
Fase 1: Fundação (1-2 dias)
  □ Configurar VPS-A com BigBase (produção)
  □ Configurar VPS-B com BigBase (staging)
  □ Configurar DNS (wildcards)
  □ Criar GitHub Environments (production + staging)
  □ Provisionar tokens scoped para cada VPS

Fase 2: Templates (2-3 dias)
  □ Estender workflow templates para multi-env
  □ Criar reusable workflows no .github org
  □ Testar com 1 repo piloto

Fase 3: Rollout (1 semana)
  □ Classificar 58 repos por categoria
  □ Bootstrap CI/CD em lotes (10 por vez)
  □ Validar staging + prod para cada lote

Fase 4: Hardening (contínuo)
  □ Configurar monitoring + alerting
  □ Backup automation
  □ Documentar runbooks
```

---

## Decisão de Arquitetura — Justificativa

### Por que 2 BigBase separados (não 1 com 2 ambientes)?

| Opção | Prós | Contras |
|-------|------|---------|
| **2 VPS, 2 BigBase** ✅ | Isolamento total; staging não afeta prod; falhas contidas | Mais manutenção |
| 1 VPS, 2 BigBase | Simples; menos VMs | Staging derruba prod se consumir RAM |
| 1 VPS, 1 BigBase, 2 ambientes | Mais simples ainda | Zero isolamento; staging quebra prod |

**Recomendação: 2 VPS, 2 BigBase** — O custo extra de manutenção é insignificante comparado ao risco de staging derrubar produção. Com 58 repos, a probabilidade de alguém deployar algo que consuma muita RAM em staging é alta.

### Por que GitHub Environments (não branches só)?

- **Proteção contra deploy acidental** — `main` requer reviewer
- **Secrets isolados** — staging não tem acesso ao token de prod
- **Audit log** — quem deployou, quando, para qual ambiente
- **Wait timer** — 5 minutos para cancelar antes do deploy subir
