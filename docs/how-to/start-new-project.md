---
type: How-to
title: Start a New Portfolio Project
description: End-to-end guide to create a new danielvm-git repo with branch protection, CI/CD, deploy wiring, brand tokens, and agent context files.
tags: [new-project, setup, bootstrap, ci-cd, deploy, brand]
timestamp: 2026-07-13
provenance: docs/how-to/new-project-quickstart.md
---

# Start a New Portfolio Project

## Overview

This guide walks you through creating a new repo in the danielvm-git portfolio. Every portfolio repo inherits CI/CD templates, deploy contracts, brand identity, and agent conventions from the `.github` template layer. Following these steps ensures your project is consistent with all 28 portfolio repos and passes CI compliance gates.

## Before you start

- You have admin access to the danielvm-git GitHub organization
- You have the [bigpowers methodology](https://github.com/danielvm-git/bigpowers) installed
- You have decided on your project's tech stack (Node.js, Python, Swift, or Rust)
- You have a descriptive repo name (kebab-case, e.g. `my-new-service`)

## Step-by-step guide

### 1. Create the GitHub repository

Create a new repository under `danielvm-git` with:
- **Repository name**: kebab-case (e.g. `my-awesome-service`)
- **Description**: One-line summary of what the project does
- **Visibility**: Private (public only if explicitly required)
- **Initialize**: Do NOT initialize with a README, .gitignore, or license (`.github` provides these)

```bash
gh repo create danielvm-git/my-awesome-service --private --description "Description here" --push
```

### 2. Configure branch protection

Apply the required branch protection rules to `main`:

```bash
gh api -X PUT repos/danielvm-git/my-awesome-service/branches/main/protection \
  --input - <<< '{
    "required_status_checks": {"strict": true, "contexts": []},
    "enforce_admins": true,
    "required_pull_request_reviews": {
      "required_approving_review_count": 1,
      "dismiss_stale_reviews": true,
      "require_code_owner_reviews": false
    },
    "restrictions": null,
    "required_conversation_resolution": true
  }'
```

See [Branch Protection Rules](../reference/branch-protection-rules.md) for the full baseline.

### 3. Run bigpowers setup

Initialize the repo with agent conventions, git hooks, and directory structure:

```bash
cd my-awesome-service
bigpowers setup
```

This creates:
- `AGENTS.md` (canonical agent context) with symlinks to `CLAUDE.md` and `GEMINI.md`
- `guard-git` pre-tool-use hooks for AI agents
- Directory structure following portfolio conventions

See [Agent Context Files](../reference/agent-context-files.md) for details.

### 4. Select and wire CI/CD workflow

Choose the correct workflow template for your stack from the [CI/CD Templates](../reference/portfolio-standards.md#cicd-templates):

| Stack | Template |
|-------|----------|
| Node.js / TypeScript | `ci-cd-monorepo.yml` |
| Python | `ci-cd-python.yml` |
| Swift | `ci-cd-swift.yml` |
| Rust | `ci-cd-rust.yml` |

Place it in `.github/workflows/`:

```bash
mkdir -p .github/workflows
cp /path/to/.github/workflow-templates/ci-cd-monorepo.yml .github/workflows/
```

### 5. Wire bigbase-deploy

Add the deploy step to your workflow by referencing the `bigbase-deploy` action:

```yaml
- name: Deploy
  uses: danielvm-git/.github/actions/bigbase-deploy@v1
  with:
    app_type: <your-app-type>
  secrets:
    BIGBASE_DEPLOY_TOKEN: ${{ secrets.BIGBASE_DEPLOY_TOKEN }}
    BIGBASE_SITE_ID: ${{ secrets.BIGBASE_SITE_ID }}
```

Provision deploy credentials:

```bash
bigbase_provision_ci_credentials my-awesome-service
```

See the [BigBase Deploy Contract](../reference/contracts/bigbase-deploy-contract.md) for valid `app_type` values and health check protocol.

### 6. Apply brand tokens

Copy the brand identity assets into your repo:

```bash
cp -r brand/ assets/brand/
```

Brand tokens include:
- Color palette (CSS custom properties and SCSS variables)
- Typography scale and font-face declarations
- Logo assets (SVG, PNG, favicon)
- Spacing and sizing tokens

The canonical source is [danielvm-git/brand_identity_danielvm](https://github.com/danielvm-git/brand_identity_danielvm). The `.github` repo mirrors these as `brand/`.

### 7. Install agent context files

If you skipped `bigpowers setup` in step 3, install manually:

```bash
ln -sf AGENTS.md CLAUDE.md
ln -sf AGENTS.md GEMINI.md
```

Verify:

```bash
ls -la CLAUDE.md GEMINI.md
# Expected: CLAUDE.md -> AGENTS.md, GEMINI.md -> AGENTS.md
```

### 8. Generate README from template

Choose the correct README template for your stack and customize:

```bash
cp /path/to/.github/templates/readmes/README-monorepo.md README.md
```

Available stack variants:
- `README-monorepo.md` — Node.js monorepo
- `README-python.md` — Python project
- `README-swift.md` — Swift project
- `README-rust.md` — Rust project
- `README-frontend.md` — Frontend web app

### 9. Push and verify CI

Push your initial commit and confirm CI passes:

```bash
git add .
git commit -m "feat: initial scaffold"
git push origin main
```

Monitor the Actions tab for the first CI run. The pipeline should:
- Run linting and type checking
- Execute tests
- Verify docs consistency
- Pass all status checks

### 10. Configure repo settings

Apply final settings through the GitHub UI or API:

- Enable **Automatically delete head branches**
- Enable **Allow squash merging** (only)
- Set **Default squash merge message** to PR title + description
- Set **Branch protection rule** to require CI passing on `main`
- Add the repo to any relevant GitHub Teams

## See also

- [Portfolio Standards](../reference/portfolio-standards.md) — All portfolio-wide conventions in one place
- [Portfolio Architecture](../concept/portfolio-architecture.md) — How the 4 template layers connect
- [Agent Context Files](../reference/agent-context-files.md) — AGENTS.md/CLAUDE.md pattern
- [Branch Protection Rules](../reference/branch-protection-rules.md) — Full rule baseline
- [CI/CD Templates](../reference/portfolio-standards.md#cicd-templates) — Available workflow templates
- [BigBase Deploy Contract](../reference/contracts/bigbase-deploy-contract.md) — Deploy contract spec
- [Brand Identity](https://github.com/danielvm-git/brand_identity_danielvm) — Brand tokens source
- [Guard Git Safety Hooks](guard-git-safety-hooks.md) — Block dangerous git operations
