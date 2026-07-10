# .github template repo — Conventions

## Conventional Commits

All commits follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

Format: `<type>(<scope>): <description>`

| Type | Bump |
|------|------|
| `feat` | Minor |
| `fix` | Patch |
| `docs`, `chore`, `refactor` | None |

## Branch Protection

- No direct work on `main`. Feature branches only.
- Squash-merge via `scripts/land-branch.sh` or `gh pr merge --squash`.
- Never push directly to `main`/`master`.

## Git Safety

- `guard-git` hooks block: push to main, force push, reset --hard, branch -D, checkout/restore .
- Install via: `bigpowers setup` → hooks auto-linked.

## Preflight

This repo's preflight is a YAML/workflow validation pass:

```bash
yamllint workflow-templates/ workflows/ actions/ && echo "Preflight: PASS"
```

If `yamllint` isn't installed: `pip install yamllint` (or skip — template repo, no runtime).

## CI

This repo uses its own `ci-shell.yml` template:
- ShellCheck on all `.sh` files
- YAML lint on workflow templates

## Agent Rules

- Route work through bigpowers skills.
- Never edit generated files (workflow-templates consumed by other repos — changes here propagate).
- Always Green: preflight must pass before forward work.
- Fix-or-log: reproducible failures get quick-fix or fix-bug, never dismissed as pre-existing.

## Never

- Never dismiss reproducible gate failures as pre-existing or out of scope
- Never proceed on red Preflight or red CI — invoke quick-fix or fix-bug first
- Never edit another repo's files from this repo — use `gh repo clone` and work there
