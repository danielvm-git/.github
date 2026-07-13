# Story e01s01: Bootstrap docs infrastructure — folder structure, OKF indexes, AGENTS.md update

**type:** refactor
**risk:** P3
**context:** infra
**bcps:** 2

## Context

The docs/ directory currently uses a loose structure inherited from early development: plural `tutorials/` folder, empty subdirectories (`agent-context/`, `ci-cd/`, `deploy/`, `metrics/`), an orphaned `compose/` directory with one file, and an `audit-history/` subdirectory that should be a single file per OKF §7. AGENTS.md references "Diátaxis" which is being deprecated in favor of Good Docs Project templates.

This story creates the structural foundation for the Good Docs + OKF refactor. It touches no content — only directories, index files, and taxonomy references. All subsequent stories depend on this structure existing.

## Requirements

#### ADDED: Good Docs folder structure under docs/
Create folders matching Good Docs Project template types: `concept/`, `how-to/`, `tutorial/`, `reference/`, `api-reference/`, `troubleshooting/`, `release-notes/`, `style-guide/`, `glossary/`.

#### ADDED: OKF bundle root index.md
Create `docs/index.md` as the portfolio entry point — lists all sections with one-line descriptions linking to each doc. This is the file other repos' agents consume.

#### ADDED: OKF log.md at bundle root
Create `docs/log.md` per OKF §7 — date-grouped entries, newest first.

#### ADDED: OKF index.md in each subfolder
Create placeholder `index.md` in every docs/ subfolder.

#### RENAMED: tutorials/ → tutorial/
**Before:** `docs/tutorials/` (plural)
**After:** `docs/tutorial/` (singular, matching Good Docs folder name)

#### REMOVED: compose/ directory
**Before:** `docs/compose/reports/consolidated-ci-cd-templates.md`
**After:** (removed) — content will be moved to reference/ in e01s02

#### REMOVED: Empty subdirectories
**Before:** `docs/how-to/agent-context/`, `docs/how-to/ci-cd/`, `docs/how-to/deploy/`, `docs/reference/metrics/`
**After:** (removed) — empty directories with no content

#### MODIFIED: AGENTS.md taxonomy
**Before:** `Docs follow Diátaxis structure (tutorials / how-to / reference / explanation).`
**After:** `Docs follow Good Docs Project templates (concept / how-to / tutorial / reference / api-reference / troubleshooting / release-notes / style-guide / glossary) with OKF frontmatter.`

## Steps

1. Create Good Docs folder structure under docs/ → verify: `for d in concept how-to tutorial reference api-reference troubleshooting release-notes style-guide glossary; do [ -d "docs/$d" ] || echo MISSING: $d; done`
2. Create OKF bundle root docs/index.md with links to all sections → verify: `head -3 docs/index.md | grep -q '# .github Documentation'`
3. Create OKF docs/log.md with initial entry → verify: `head -5 docs/log.md | grep -q '2026-07-13'`
4. Create placeholder index.md in each Good Docs subfolder → verify: `for d in concept how-to tutorial reference api-reference troubleshooting release-notes style-guide glossary; do [ -f "docs/$d/index.md" ] || echo MISSING: docs/$d/index.md; done`
5. Rename docs/tutorials/ to docs/tutorial/ and move content → verify: `[ -d docs/tutorial ] && [ ! -d docs/tutorials ]`
6. Remove docs/compose/ directory (content preserved for e01s02 move) → verify: `[ ! -d docs/compose ]`
7. Remove empty subdirectories (agent-context/, ci-cd/, deploy/, metrics/) → verify: `find docs -type d -empty | wc -l | grep -q '^0'`
8. Update AGENTS.md to replace Diátaxis with Good Docs + OKF taxonomy → verify: `grep -q 'Good Docs Project' AGENTS.md`
9. Check if CONVENTIONS.md references Diátaxis and update if needed → verify: `grep -q 'Diátaxis' CONVENTIONS.md && echo 'NEEDS UPDATE' || echo 'OK'`

## Verification Script (Step-by-Step)

1. Run `find docs -type d | sort` — confirm Good Docs folders exist, old folders removed
2. Run `cat docs/index.md` — confirm it lists all sections with descriptions
3. Run `cat docs/log.md` — confirm initial entry present
4. Run `for d in docs/*/index.md; do echo "$d: $(head -1 $d)"; done` — confirm all indexes have content
5. Run `ls docs/tutorial/` — confirm tutorial content migrated from tutorials/
6. Run `grep 'Good Docs' AGENTS.md` — confirm taxonomy updated
7. Run `grep 'Diátaxis' AGENTS.md` — should return nothing

## Out of scope

- Content migration (e01s02) — this story only creates structure
- Writing new docs (e01s03, e01s04)
- Auto-generation tooling (e01s05)
- OKF frontmatter on existing docs (e01s02)

## Risks

- Moving compose/reports/consolidated-ci-cd-templates.md before content migration could lose the file. Mitigation: remove directory in step 6 but preserve file content reference in epic.yaml for e01s02.
- AGENTS.md symlink propagation: updating AGENTS.md in .github may not propagate to repos that have divergent copies (known issue from bigpowers-learnings.md). This is a known bug tracked separately — not in scope for this story.
