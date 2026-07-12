# Align an existing repo to the .github standard

> **Audience:** Repo maintainers migrating an existing `danielvm-git/*` project to the portfolio standard.
> **Prerequisites:** Repo cloned locally under `~/Developer/`. BigBase deploy token provisioned if the project deploys.

## Checklist

Tick each item as you complete it. Items marked **(P0)** gate the PR from landing.

### 1. Agent context files **(P0)**

```bash
# If CLAUDE.md and GEMINI.md are regular files (not symlinks):
# 1. Pick the most complete file as canonical
# 2. Consolidate into AGENTS.md
# 3. Replace others with symlinks:
rm CLAUDE.md GEMINI.md
ln -s AGENTS.md CLAUDE.md
ln -s AGENTS.md GEMINI.md

# Verify:
test -L CLAUDE.md && echo "✅ CLAUDE.md is symlink"
test -L GEMINI.md && echo "✅ GEMINI.md is symlink"
```

See `docs/reference/agent-context-files.md` for the canonical setup.

### 2. README **(P1)**

- [ ] Build Status badge links to the Actions tab
- [ ] Commands table matches actual scripts in `package.json` / `Makefile` / `Justfile`
- [ ] Preflight row lists the full-green command (`npm test && npm run lint && npm run build` or equivalent)
- [ ] Tech Stack table is correct
- [ ] Contribute section points to `CONTRIBUTING.md` or Conventional Commits

Use `templates/readmes/` for stack-specific sections. If your stack isn't listed, use `templates/readmes/template-README.md` as a skeleton and fill in repo-specific content.

### 3. CI/CD workflow **(P0)**

- [ ] Workflow lives at `.github/workflows/ci-cd-<language>.yml` (copy from `workflow-templates/`)
- [ ] Template matches project stack: `ci-cd-node.yml`, `ci-cd-python.yml`, `ci-cd-go.yml`, `ci-cd-static.yml`, `ci-cd-swift.yml`, `ci-cd-monorepo.yml`
- [ ] For docs sites: `ci-cd-pages-mkdocs.yml` or `ci-cd-pages-starlight.yml`
- [ ] Actions pinned per `docs/explanation/github-actions-best-practices.md` tier:
  - **Third-party actions with write/secrets access:** pin to full commit SHA
  - **First-party `actions/*`:** major-version tags acceptable (`@v4`, `@v5`)
  - **Never `@master` or `@main`** for any action
- [ ] `permissions: contents: read` at workflow level
- [ ] `timeout-minutes` set on every job
- [ ] `concurrency` group set at workflow level
- [ ] `runs-on: ubuntu-22.04` (not `-latest`)

Run the CI on your branch and confirm it's green before opening a PR.

### 4. Deploy auth **(P0)** — BigBase projects only

If the project deploys to BigBase:

- [ ] Deploy uses `BIGBASE_DEPLOY_TOKEN` (scoped), never `BIGBASE_EMAIL`/`BIGBASE_PASSWORD`
- [ ] Deploy step uses `danielvm-git/.github/actions/bigbase-deploy@main` or matches the action's contract
- [ ] `BIGBASE_SITE_ID` secret is set in repo settings
- [ ] Health check verifies the site is live after deploy

See `docs/reference/contracts/bigbase-deploy-contract.md`.

### 5. CONVENTIONS.md **(P1)**

- [ ] If the repo has `CONVENTIONS.md`, verify it's accurate
- [ ] If missing, copy from `templates/conventions/` or adapt from `bigbase/CONVENTIONS.md`
- [ ] "Always Green" / fix-or-log doctrine is documented

### 6. Preflight **(P1)**

```bash
# Every repo should have a single preflight command that gates landing:
npm test && npm run lint && npm run build   # Node/Vue
pytest && ruff check . && mypy src/         # Python
swift test && swift build                   # Swift
# etc.
```

Add to README Commands table as `Preflight`.

### 7. Brand tokens **(P2)**

```bash
# If the project has a frontend:
~/Developer/.github/scripts/pull-brand-tokens.sh .
```

### 8. Verify

```bash
# Run the audit script against this repo:
~/Developer/.github/scripts/audit-workflows.sh --repo $(basename $(pwd))

# Confirm preflight passes:
# (your preflight command here)
```

## After alignment

1. Commit with `chore: align to .github portfolio standard`
2. Push to `refactor/align-dotgithub-conventions`
3. Open a PR with `gh pr create`
4. Merge after CI is green

## Common issues

| Symptom | Fix |
|---------|-----|
| `bigbase-deploy` action fails with "token not set" | Provision `BIGBASE_DEPLOY_TOKEN` in repo secrets. See BigBase admin panel. |
| ESLint 9 flat config error | Create `eslint.config.js` with `@vue/eslint-config-typescript`. See `templates/readmes/vue-README.md`. |
| `ruff` catches violations that `black`+`isort` ignored | Run `ruff check --fix` once, commit the fixes separately. |
| `concurrency` group name conflicts with existing | Use `ci-${{ github.workflow }}-${{ github.ref }}` pattern. |
