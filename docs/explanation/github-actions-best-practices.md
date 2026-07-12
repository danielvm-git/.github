# GitHub Actions Learnings — for bigbase MCP project scaffolding

Condensed, actionable rules distilled from official GitHub hardening docs plus a full audit of all 28 danielvm-git repos (54 workflow files, scanned from local clones in `/Users/danielvm/Developer`). Intended as a checklist bigbase MCP can apply when scaffolding or reviewing new projects' `.github/workflows/`.

**Portfolio baseline (what to beat):** 52% of files have no `permissions:` block, 83% have no `timeout-minutes`, 74% have no `concurrency` group, 96% use a `-latest` runner. Reference template worth copying from: `bigflint` — the only repo with real SHA-pinning discipline and a CodeQL scan wired in.

## Always do (non-negotiable defaults for new workflows)

1. Set `permissions: contents: read` at the workflow level; escalate per-job only when a step needs write access (e.g. `pages: write`, `issues: write`).
2. Set `timeout-minutes` on every job. 10–15 for lint/test, 20–30 for deploy.
3. Pin runner OS to a version (`ubuntu-22.04`), never `-latest`.
4. Add a `concurrency` group with `cancel-in-progress: true` on CI/test workflows (cancels stale runs on rapid pushes); use `cancel-in-progress: false` on deploy workflows (queue instead of interrupting a live deploy).
5. Pass untrusted input (PR titles, issue bodies, branch names) through `env:` vars, never inline into `run:` strings.
6. Never use `pull_request_target` unless you've explicitly audited why — default to `pull_request`.

## SHA-pin third-party actions, tiered by risk

Not all actions carry equal risk — pin in this order of priority:

- **Always pin to full commit SHA:** any action with write access to secrets, SSH keys, or deploy targets (e.g. `appleboy/ssh-action`, `appleboy/scp-action`, `peaceiris/actions-gh-pages`, anything touching `gh-pages` or a VPS).
- **Always pin:** third-party Docker-based actions — use the image digest (`@sha256:...`), not a version tag, if the action has write permissions or an API key.
- **Acceptable to leave on major-version tags:** first-party `actions/*` (checkout, setup-node, setup-go, upload-artifact, etc.) — GitHub-owned, lower risk, and the version comment convention (`@v4 # v4.3.1`) is fine if your org accepts that tradeoff for readability.

## Structural patterns worth reusing (already proven in bigbase)

- **Single pipeline per repo (ci → verify → semantic-release → deploy):** Every `ci-cd-*.yml` template follows a 4-job pipeline. The `ci` job runs lint/test/build, `verify` runs preflight + conventional commits, `semantic-release` handles versioning, and `deploy` conditionally calls `bigbase-deploy`. This is one-piece flow — no handoffs between separate workflow files. See any `ci-cd-*.yml` template in `workflow-templates/`.
- **Fast/slow split via `workflow_dispatch` input:** run cheap checks (lint, unit tests) on every push/PR; gate expensive checks (full installer verification, integration suites) behind a manual `workflow_dispatch` boolean input. See `big-token-saver/ci.yml`.
- **Backup → deploy → health-check → auto-rollback:** for any deploy workflow touching a live server, snapshot the current binary/DB before deploying, poll a health endpoint with retries after deploy, and automatically restore the snapshot on failure. See `bigbase/release-deploy.yml`.
- **Least-privilege permissions per job, not per workflow:** a PR-review bot job needs `issues: write, pull-requests: write` but not `contents: write`; a docs-deploy job needs `pages: write, id-token: write` but not `issues`. Scope at the job level when jobs in the same workflow have different needs.

## Common gaps to check for in new/imported projects

- Deploy workflow with no concurrency group (risk: two deploys racing if push + manual dispatch overlap).
- SSH/SCP/deploy actions still on version tags instead of SHAs.
- Missing `timeout-minutes`, defaulting to GitHub's 6-hour ceiling.
- `ubuntu-latest` instead of a pinned version.

## Portfolio-specific fixes worth doing once, everywhere

- `bigbase/release-deploy.yml`: SHA-pin `appleboy/scp-action` and `appleboy/ssh-action` — they hold SSH deploy credentials, currently on version tags.
- `sqz`: `dtolnay/rust-toolchain@master` / `@stable` — pinned to a moving branch/alias, the weakest pinning found anywhere in the portfolio. Pin to a version at minimum, SHA ideally.
- Mechanical/scriptable fix: add `permissions: contents: read` to the 28 workflow files across the portfolio that currently omit it entirely.

## Reference

Primary source: GitHub's own [Security hardening for GitHub Actions](https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions). Community sources (Exercism, StepSecurity, Zup) converge on the same points.
