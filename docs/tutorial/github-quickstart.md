---
type: Tutorial
title: GitHub Quickstart — First Steps
description: Guided walkthrough for setting up a new danielvm-git project with the portfolio standard.
tags: [tutorial, quickstart, portfolio, setup]
timestamp: 2026-07-13
provenance: docs/tutorial/new-project-quickstart.md
---

# GitHub Quickstart — First Steps

Consolidação de tudo discutido nesta conversa (auditoria de 28 repos, padrão de deploy no bigbase, guia de Pages/Wikis, Diátaxis/Good Docs/OKF, aprendizados do bigpowers, e revisão dos repos soltos). Ordenado por dependência — cada passo assume que o anterior foi feito.

## Passo 0 — corrigir o que já está quebrado

1. **Symlink drift do AGENTS.md/CLAUDE.md/GEMINI.md.** Rode `seed-conventions` novamente nos repos afetados.
2. **Repos sem README**: `big-quiqui`, `big-olive-books` precisam de README mínimo.
3. **`presets/brand-sdd/` dentro de `brand_identity_danielvm`**: mova para bigpowers ou `.github`.

## Passo 1 — criar o repositório

Crie `danielvm-git/.github` (nome especial — GitHub aplica automaticamente em toda conta).

## Passo 2 — popular `workflow-templates/` e `workflows/`

1. Copie `grimoire/.github/workflows/docs.yaml` → `workflow-templates/deploy-pages.yml`
2. Escreva `security-baseline.yml` com `permissions`, `timeout-minutes`, `concurrency`
3. Templates por stack: Node, Go, Python, Static, Monorepo
4. Adicione `.properties.json` em cada template

## Passo 3 — construir e endurecer o `bigbase-deploy`

Crie `actions/bigbase-deploy/action.yml` com inputs `site_id`, `app_type`, `site_url`. Autenticação por token escopado por site.

## Passo 4 — trazer os docs já escritos

Os docs existentes (auditoria, learnings, guias) vão para `docs/explanation/`, `docs/reference/audit-history/`, etc.

## Passo 5 — resolver os repos soltos

| Repo | Ação |
|------|------|
| `skill-method-manager`, `clean-install-guide` | Já arquivados |
| `big-kickass-readme` | Mover para `templates/readmes/`, arquivar original |
| `semantic-release-baby` | Confirmar conteúdo |
| `dev-checklist` | Manter separado |
| `brand_identity_danielvm` | Manter separado |

## Passo 6 — conectar a identidade visual

`brand_identity_danielvm/brand/tokens.css` é o design system — refine a partir daí.

## Passo 7 — ir ao ar

1. Commit inicial com estrutura completa
2. Rode `scripts/audit-workflows.sh` contra os 28 repos
3. Teste com 1 repo piloto
4. Siga o fluxo bigpowers completo
5. Após ciclo funcionar, torne público e migre demais repos
