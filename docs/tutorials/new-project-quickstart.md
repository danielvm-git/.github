---
type: how-to
title: Plano de execução — deixar o .github reference repo pronto e live
---

# Plano de execução — .github reference repo

Consolidação de tudo discutido nesta conversa (auditoria de 28 repos, padrão de deploy no bigbase, guia de Pages/Wikis, Diátaxis/Good Docs/OKF, aprendizados do bigpowers, e revisão dos repos soltos). Ordenado por dependência — cada passo assume que o anterior foi feito.

## Passo 0 — corrigir o que já está quebrado (antes de criar qualquer coisa nova)

Isso não depende do repo novo existir, e alguns já estão causando drift silencioso hoje:

1. **Symlink drift do AGENTS.md/CLAUDE.md/GEMINI.md.** Confirmado por timestamp que pelo menos `big-stream`, `big-clipboard-manager`, `big-olive-books`, `big-quiqui`, `big-kickass-readme`, `big-dock-locker`, `big-dock-locker-site` têm os três arquivos como cópias reais divergentes, não symlinks (como o `seed-conventions` do bigpowers pretende). Rode o `seed-conventions` de novo (ou um script de reparo) nesses repos pra restabelecer o symlink, e investigue o que no fluxo (provavelmente algo que desreferencia symlinks ao copiar/transferir) quebrou isso.
2. **3 repos sem README**: `big-quiqui`, `big-olive-books`, `clean-install-guide`. Este último já está arquivado, então ignora. Os outros dois precisam de um README mínimo antes de qualquer outra coisa — sem isso, ninguém (nem agente nem humano) sabe o que o repo faz.
3. **`presets/brand-sdd/` dentro de `brand_identity_danielvm`** — mova esses comandos Spec-Kit pra fora (pro bigpowers ou pro `.github`). Esse repo deve conter só marca/design.

## Passo 1 — criar o repositório

Crie `danielvm-git/.github` (nome especial — GitHub aplica automaticamente em toda conta). Pode começar privado e abrir depois; os efeitos de `workflow-templates/` e community health files funcionam nos dois casos.

## Passo 2 — popular `workflow-templates/` e `workflows/`

1. Copie `grimoire/.github/workflows/docs.yaml` quase como está → vira `workflow-templates/deploy-pages.yml` (já segue best practice: MkDocs, `actions/deploy-pages`, permissions escopadas, concurrency).
2. Escreva `security-baseline.yml` com os 3 itens que faltam em 52-83% dos workflows hoje: `permissions: contents: read` no topo, `timeout-minutes`, `concurrency` com `cancel-in-progress`.
3. Um template por tipo de projeto (`ci-node.yml`, `ci-go.yml`, `ci-python.yml`, `ci-rust.yml`, `ci-static-site.yml`) — use `bigflint` como base pro Go (é o único repo com SHA-pinning real e CodeQL já configurado).
4. Adicione `.properties.json` em cada um pra aparecer certo no picker do GitHub.

## Passo 3 — construir e endurecer o `bigbase-deploy`

Esse é o mais crítico porque já tem 4 implementações divergentes rodando em produção (`astrobiologia`, `big-bolao`, `big-library`, `big-olive-books`):

1. Escreva `actions/bigbase-deploy/action.yml` com os inputs `site_id`, `app_type`, `site_url`.
2. Autenticação: **token escopado por site** (o padrão que `astrobiologia` já usa), não email/senha. Migre `big-bolao`, `big-library`, `big-olive-books` pra esse método — são credenciais de conta completa hoje, não de um site só.
3. Sempre `::add-mask::` no token logo após obtê-lo (só `big-bolao` faz isso hoje).
4. Não faça `git commit` do build output de volta pro `main` (remova esse passo de `big-bolao` e `big-library`) — suba o artefato de build direto pro passo de deploy via `actions/upload-artifact`.
5. Um retry de health-check só, parametrizado (hoje são 4 loops de curl quase idênticos, mantidos separadamente).

## Passo 4 — trazer os docs já escritos nesta conversa

Estes já existem como arquivos prontos — só precisam ir pro lugar certo em `docs/`:

- `github-actions-audit.md` → `docs/reference/audit-history/2026-07-audit.md`
- `github-actions-learnings.md` → mescla dentro de `docs/explanation/github-actions-best-practices.md`
- `github-pages-and-wikis-guide.md` → `docs/explanation/`
- `bigpowers-learnings.md` → `docs/explanation/`

Depois crie os que ainda faltam: `docs/reference/metrics/dx-core-4-metrics.md` (estendendo o pipeline DORA que o bigpowers já roda em `specs/metrics/*.okf.md`), `docs/how-to/agent-context/fix-agents-md-symlink-drift.md` (documentando o Passo 0.1), `docs/reference/contracts/bigbase-deploy-contract.md` (nomes de secrets, convenção de `site_id`, `app_type`s suportados).

## Passo 5 — resolver os repos soltos

| Repo | Ação |
|---|---|
| `skill-method-manager`, `clean-install-guide` | já arquivados — só confirme "Archived" nas Settings do GitHub |
| `big-kickass-readme` | mova conteúdo pra `templates/readmes/`, arquive o repo original |
| `semantic-release-baby` | confirme o conteúdo; se for config de semantic-release, vira `.releaserc.shared.json` aqui e arquiva o original |
| `dev-checklist` | mantenha separado; troque a lógica duplicada em `scripts/audit-workflows.sh` por uma chamada ao `stack-check` dele |
| `brand_identity_danielvm` | mantenha separado; `.github/brand/README.md` só aponta pra lá |

Registre cada decisão em `docs/explanation/repo-disposition-log.md` com data — é o mesmo princípio do `audit-history/`: não sobrescrever, deixar rastro.

## Passo 6 — conectar a identidade visual

`brand_identity_danielvm/brand/tokens.css` já é o design system (OKLCH, 6 temas, tipografia, dark mode) — não recrie no claude.ai/design, refine a partir daí. Adicione um passo no `seed-conventions` do bigpowers (ou um novo comando) que copia esse `tokens.css` pra qualquer projeto novo com UI, do mesmo jeito que já copia `AGENTS.md`/`CONVENTIONS.md`.

## Passo 7 — ir ao ar

1. Commit inicial com a estrutura completa.
2. Rode `scripts/audit-workflows.sh` uma vez contra os 28 repos reais — esse é o primeiro `audit-history/` de verdade, não mais um export de conversa.
3. **Teste com 1 repo piloto**: escolha um projeto pequeno e sem CI hoje (ex.: `big-server-monitor`), aplique o template certo, o `bigbase-deploy`, confirme `AGENTS.md` único, puxe os tokens de marca.
4. **Lande sua primeira feature**: siga o fluxo bigpowers completo — `kickoff-branch` → `develop-tdd` → `verify-work` → `audit-code` → `release-branch`. O `release-branch` roda `scripts/land-branch.sh` (squash-merge local) ou `gh pr create` (team mode) e dispara semantic-release. O workflow `release-branch.yml` roda preflight em CI antes do merge. O `guard-git` bloqueia push direto no `main`.
5. Só depois desse ciclo completo funcionar de ponta a ponta num repo real, torne o repo público (se for o objetivo) e comece a migrar os demais repos, um de cada vez, não em massa.
