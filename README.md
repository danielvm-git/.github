# danielvm-git/.github

`bigpowers` builds one project. This repo builds the fleet.

If you're starting a new project: run `bigpowers setup` first (methodology, specs/, conventions — see `docs/explanation/bigpowers-learnings.md` for why this repo doesn't duplicate any of that). Then come here for the cross-repo layer bigpowers doesn't cover: which CI template to pick, how to wire up bigbase-deploy, and how the design tokens from `brand_identity_danielvm` get pulled in.

## Where to start

| You want to... | Go to |
|---|---|
| Set up CI for a new project | `workflow-templates/` — GitHub's own picker will offer these automatically in a new repo's Actions tab |
| Deploy to bigbase.click | `actions/bigbase-deploy/` + `docs/reference/contracts/bigbase-deploy-contract.md` |
| Write a README | `templates/readmes/<stack>-README.md` |
| Understand a past decision | `docs/explanation/` |
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

## Conventions this repo follows (and expects)

See `AGENTS.md` — this repo dogfoods its own agent-context convention: one canonical file, `CLAUDE.md`/`GEMINI.md` are real symlinks to it, not copies.
