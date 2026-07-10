---
bug_id: BUG-2026-07-10-fleet-feedback-p2
status: open
severity: medium
scope: all
title: Fleet feedback P2/P3 — missing templates and polish items
discovered: field reports (9 GitHub issues, deferred from round 2)
created: 2026-07-10
---

## Summary

The round 2 fix-bug cycle resolved all P0/P1 items. This bug tracks the 17 deferred P2/P3 items — mostly creating missing template files and small quality-of-life improvements.

## Bug Inventory

### P2 — Template files to create

1. **ISSUE_TEMPLATE/** — empty directory. Needs `bug_report.yml`, `feature_request.yml`, `config.yml`.
2. **`.pre-commit-config.yaml` template** — `templates/pre-commit/python-pre-commit.yaml`
3. **`.gitignore` templates** — per-stack: python, node, vue, swift, rust, go, godot
4. **`.releaserc.shared.json`** — `templates/semantic-release/.releaserc.shared.json`
5. **`ci-python-uv.yml`** — uv-based Python CI (Grimoire and others use uv, not pip)
6. **CodeQL templates** — `codeql-python.yml` + `codeql-javascript.yml`
7. **Game engine README** — `templates/readmes/game-README.md`
8. **Generic README** — `templates/readmes/generic-README.md`
9. **ruff migration guide** — `docs/how-to/migrate-black-isort-to-ruff.md`
10. **`ci-python-matrix.yml`** — multi-version Python CI variant

### P2 — Template fixes

11. **`deploy-pages-mkdocs.yml` retry** — backport retry pattern from starlight template
12. **`golangci-lint-action` SHA-pin** — `ci-go.yml` has a TODO for this
13. **README templates BigBase-aware** — add BigBase deploy section to applicable READMEs

### P3 — Nice-to-have

14. **Template versioning** — `# @template: ci-python v2.1.0` headers + sync script (design needed)
15. **Template changelog** — `workflow-templates/CHANGELOG.md`
16. **Multi-stack CI template** — for repos mixing Node + Go, Python + Vue, etc.
17. **Template test harness** — minimal hello-world repos exercising each template via `act`

## Fix Approach

P2 items are mostly file creation. P3 items need design decisions — file separately.

## Verify Steps

→ verify:
```bash
# P2 templates exist
test -d ISSUE_TEMPLATE && ls ISSUE_TEMPLATE/*.yml | wc -l | xargs -I{} test {} -ge 3
test -f templates/pre-commit/python-pre-commit.yaml
test -f templates/gitignore/python.gitignore
test -f templates/gitignore/node.gitignore
test -f templates/semantic-release/.releaserc.shared.json
test -f workflow-templates/ci-python-uv.yml
test -f workflow-templates/codeql-python.yml
test -f workflow-templates/codeql-javascript.yml
test -f templates/readmes/game-README.md
test -f templates/readmes/generic-README.md
test -f docs/how-to/migrate-black-isort-to-ruff.md
test -f workflow-templates/ci-python-matrix.yml
```
