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

## Resolution (2026-07-10)

### ✅ Done (15 of 17)

| # | Item | Commit |
|---|------|--------|
| 1 | ISSUE_TEMPLATE/ (bug_report, feature_request, config) | 68c362b |
| 2 | templates/pre-commit/python-pre-commit.yaml | 68c362b |
| 3 | 7 gitignore templates (python, node, vue, swift, rust, go, godot) | 68c362b |
| 4 | templates/semantic-release/.releaserc.shared.json | 68c362b |
| 5 | workflow-templates/ci-python-uv.yml | 68c362b |
| 6 | workflow-templates/codeql-python.yml + codeql-javascript.yml | 68c362b |
| 7 | templates/readmes/game-README.md | 68c362b |
| 8 | templates/readmes/generic-README.md | 68c362b |
| 9 | docs/how-to/migrate-black-isort-to-ruff.md | 68c362b |
| 10 | workflow-templates/ci-python-matrix.yml | 68c362b |
| 11 | deploy-pages-mkdocs.yml retry backport | 68c362b |
| 12 | golangci-lint replaced with curl install in ci-go.yml | 68c362b |
| 13 | README templates BigBase-aware (astro, vue, sveltekit) | 68c362b |

### ⚠️ Deferred P3 (needs design before implementation)

| # | Item | Why deferred |
|---|------|-------------|
| 14 | Template versioning headers + sync script | Needs decision: Renovate vs manual sync vs workflow_call refs |
| 15 | workflow-templates/CHANGELOG.md | Blocked on template versioning (no versions to log without it) |
| 16 | Multi-stack CI template | Needs design: compose via matrix vs separate workflow files vs reusable workflow_call |
| 17 | Template test harness (act-based) | Needs `act` setup + hello-world repos per stack |

### Portfolio state after this fix

- **15 workflow templates** (up from 11): go, node, python, python-uv, python-matrix, rust, shell, static-site, swift, vue-spa, mkdocs, starlight, release-branch, codeql-python, codeql-javascript
- **All 15 have .properties.json** for GitHub native picker
- **All 15 have security baseline** (permissions, concurrency, timeout-minutes)
- **All pinned to ubuntu-22.04**
- **All trigger on [main, develop, master]**
- **9 template categories**: gitignore (7 stacks), pre-commit (python), semantic-release (.releaserc), readmes (14 stacks), issue templates (3 files)

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
