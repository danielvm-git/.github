# danielvm-git/.github

`bigpowers` builds one project. This repo builds the fleet.

If you're starting a new project: run `bigpowers setup` first (methodology, specs/, conventions — see `docs/explanation/bigpowers-learnings.md` for why this repo doesn't duplicate any of that). Then come here for the cross-repo layer bigpowers doesn't cover: which CI template to pick, how to wire up bigbase-deploy, and how the design tokens from `brand_identity_danielvm` get pulled in.

## Where to start

| You want to... | Go to |
|---|---|
| Set up CI/CD for a new project | `workflow-templates/` — copy the `test-build-release-<stack>.yml` + `deploy-<stack>.yml` pair to `.github/workflows/test-build-release.yml` + `deploy.yml` (see `docs/how-to/start-new-project.md` §4) |
| Deploy to bigbase.click | `actions/bigbase-deploy/` + `docs/reference/contracts/bigbase-deploy-contract.md` |
| Write a README | `templates/readmes/<stack>-README.md` |
| Understand a past decision | `docs/explanation/` |
| Wire MCP servers into any tool | `docs/reference/mcp-config-matrix.md` |
| Look something up | `docs/reference/` |
| See portfolio health over time | `docs/reference/audit-history/` |

## Structure

- `workflow-templates/` — appears natively in every new repo's Actions tab (GitHub's own mechanism, not a convention you have to remember)
- `workflows/` — reusable pieces referenced by SHA from project repos
- `actions/bigbase-deploy/` — the one deploy step every project calls
- `templates/readmes/` — one per stack, Kickass-README-based
- `docs/` — Diátaxis-structured (tutorials / how-to / reference / explanation), grows indefinitely
- `brand/` — pointer to `brand_identity_danielvm`, not a copy
- `scripts/` — portfolio-wide audit tooling

## How deploys run

Deploys run inside a GitHub Actions workflow through the shared [`bigbase-deploy`](actions/bigbase-deploy/) composite action. The action takes a scoped deploy token, masks it, `POST`s to `https://bigbase.click/api/sites/<site_id>/deploy`, then retries a health check (8× / 10s) against `site_url` until it returns 200/301/302. See the [bigbase-deploy contract](docs/reference/contracts/bigbase-deploy-contract.md) for required secrets and `app_type` values.

Deploys are not triggered by hand. In the canonical layout, `deploy.yml` runs on `workflow_run` of the `Test Build Release` pipeline and deploys only when that run succeeded on `main`. To ship, merge to `main`. To redeploy the same commit, re-run the last successful pipeline run on `main`.

### Prerequisites

- `BIGBASE_SITE_ID` and `BIGBASE_DEPLOY_TOKEN` secrets set on the repo — the token is scoped to one site, provisioned via `bigbase_provision_ci_credentials`; never use account email/password.
- `SITE_URL` set in `deploy.yml` (the `Health check` step checks this URL).

### Redeploy the current `main`

```bash
# From inside the project repo:
RUN_ID=$(gh run list --workflow test-build-release.yml --branch main --status success --limit 1 --json databaseId --jq '.[0].databaseId')
gh run rerun "$RUN_ID"
```

When the re-run completes, it fires `workflow_run` again and `deploy.yml` deploys.

### Watch it

```bash
gh run watch            # follows the most recent run
gh run list --limit 5   # or list recent runs
gh run view --log       # inspect logs / health-check output
```

A green run ending in `✅ Site LIVE` means the health check passed and the site is up at `SITE_URL`.

## Conventions this repo follows (and expects)

See `AGENTS.md` — this repo dogfoods its own agent-context convention: one canonical file, `CLAUDE.md`/`GEMINI.md` are real symlinks to it, not copies.
