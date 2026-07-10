# danielvm-git/.github — AI Agents

> **Multi-agent context** — This file is the canonical project context for **Cline**, **Aider**, **OpenCode**, and other AGENTS.md-native tools. Claude Code and Cursor read it via the `CLAUDE.md` symlink.

Read CONVENTIONS.md before any GitHub or git operation.

<!-- BEGIN bigpowers:context-routing -->
## Context Routing

| Glob / trigger | Load first |
|----------------|------------|
| `workflow-templates/**` | `docs/reference/contracts/` for deploy contracts |
| `templates/readmes/**` | Template itself — self-documenting |
| `docs/**` | Matching doc under `docs/` |
| Default / session start | This file → `CONVENTIONS.md` → `specs/state.yaml` |
<!-- END bigpowers:context-routing -->

<!-- BEGIN bigpowers:learned-preferences -->
## Learned User Preferences

- Follow bigpowers fix-or-log — never dismiss gate failures.
- Use `rtk`-prefixed shell commands for git, test, build output.
- Prefer `gh` CLI over raw `git push` / `curl` for GitHub operations.

## Workspace Facts

- This repo is the **portfolio template layer** — it provides CI/CD, README, and deploy templates that every danielvm-git repo inherits.
- `workflow-templates/` appears natively in GitHub's Actions tab for new repos.
- `brand/` points to `brand_identity_danielvm`, not a copy.
- `bigbase-deploy` action is the single deploy step every project calls.
- Stack: Markdown / YAML / Bash (documentation and template repo).
- 28 portfolio repos share these templates.
<!-- END bigpowers:learned-preferences -->

<!-- BEGIN bigpowers:project -->
## Project

Portfolio-wide template layer for danielvm-git — CI/CD workflows, README templates, deploy actions, and agent context that every repo inherits.
Stack: Markdown, YAML, Bash

## Commands

| Action | Command |
|--------|---------|
| Preflight | `yamllint workflow-templates/ workflows/ actions/` |
| Lint | `shellcheck scripts/*.sh` (if shell scripts present) |
| Test | N/A (template repo, validation via yamllint) |
| Build | N/A |
| CI | `gh pr checks` (when a PR is open) |

## Architecture

Three layers: **templates** (workflow-templates/, templates/readmes/) consumed by other repos → **actions** (actions/bigbase-deploy/) called by those workflows → **documentation** (docs/) explaining the cross-repo layer bigpowers doesn't cover.

## Conventions

- Conventional Commits on all changes; `feat:` = minor, `fix:` = patch
- No direct work on `main` — feature branches only, squash-merge via `scripts/land-branch.sh`
- `guard-git` hooks block dangerous git operations
- `bigpowers` owns methodology; this repo owns CI/CD, deploy, and README templates
- Branch protection: require PR, require CI pass, no force-push
- Docs follow Diátaxis structure (tutorials / how-to / reference / explanation)

## Never

- Never dismiss reproducible gate failures as pre-existing or out of scope
- Never proceed on red Preflight or red CI — invoke quick-fix or fix-bug first
- Never edit another repo's files from this repo
- Never duplicate bigpowers methodology — this repo extends, not replaces

## Agent Rules

- **Workflow Mandate:** Use bigpowers skills (e.g. `plan-work`, `develop-tdd`) for structured work.
- **Always Green:** Preflight and CI must be green before forward work.
- Read specs/ and CONVENTIONS.md before writing code.
- Write the minimum code that solves the stated problem.
- All planning output goes in specs/.
- New workflow templates must include `concurrency` group and `timeout-minutes`.
- README template changes must stay synchronized across all stack variants.
<!-- END bigpowers:project -->
