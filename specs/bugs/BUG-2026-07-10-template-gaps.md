---
bug_id: BUG-2026-07-10-template-gaps
status: open
severity: high
scope: all
title: .github template repo missing bigpowers alignment — 13 gaps
discovered: manual audit
created: 2026-07-10
---

## Summary

The `.github` template repo provides CI templates, README templates, and deploy actions for the danielvm-git portfolio. However, it has 13 gaps that prevent seeded repos from consistently following bigpowers conventions — particularly around `release-branch`, preflight, and git safety.

## Root Cause

The `.github` repo was built as a standalone template collection before the bigpowers patterns fully matured. The `release-branch` skill, `land-branch.sh`, `guard-git` hooks, and the Always Green / fix-or-log doctrine are all established in bigpowers but not reflected in the template repo's artifacts.

## Gap Inventory (13 items)

### P0 — Blockers
1. **`scripts/land-branch.sh` missing** — Every bigpowers repo needs this for solo-local squash-merge. Currently only in bigpowers/.
2. **No `CONVENTIONS.md`** — AGENTS.md references it but file doesn't exist.
3. **AGENTS.md has placeholders** — `[One sentence...]`, `[cmd]`, `[language, framework, runtime]` never filled in.

### P1 — High
4. **No preflight script template** — Always Green requires runnable preflight; each repo invents its own.
5. **No semantic-release config template** — `release-branch` needs `.releaserc.json`; repos would configure differently.
6. **No `guard-git` hook docs** — Git safety hooks live in bigpowers but activation docs belong here.
7. **No branch protection baseline doc** — P1 rule "no direct work on main" needs documented standard settings.
8. **No `release-branch` CI workflow template** — Pre-land verification should run in CI, not just locally.

### P2 — Medium
9. **`scripts/` directory empty** — Should contain reusable shell utilities (`land-branch.sh`, preflight orchestrator, commit-lint).
10. **No `fix-bug` flow docs** — fix-or-log pattern undocumented outside bigpowers CONVENTIONS.md.
11. **No agent-context symlink doc** — AGENTS.md → CLAUDE.md/GEMINI.md symlink pattern needs canonical setup instructions.
12. **No `specs/` for this repo** — Dogfood violation: mandates specs/ for others but has none itself.
13. **Not dogfooding CI** — Has `ci-shell.yml` template but doesn't run it on self.

### P3 — Nice-to-have
14. **No DORA rollup script** — Portfolio-wide metrics aggregation called for in bigpowers-learnings.md but not built.
15. **README templates lack Preflight section** — Every bigpowers repo needs one.
16. **Quickstart missing release-branch step** — `new-project-quickstart.md` walks through setup but stops before branching/release.

## Fix Approach

Work through P0→P3, creating each missing artifact. This is a documentation/scripting task — no runtime to break.

## Verify Steps

→ verify:
```bash
# P0
test -f scripts/land-branch.sh && echo "PASS: land-branch.sh exists"
test -f CONVENTIONS.md && echo "PASS: CONVENTIONS.md exists"
grep -q '\[One sentence' AGENTS.md && echo "FAIL: placeholders still present" || echo "PASS: AGENTS.md filled"

# P1
test -f scripts/preflight.sh && echo "PASS: preflight.sh exists"
test -f templates/semantic-release/.releaserc.json && echo "PASS: semantic-release config exists"
test -f docs/how-to/git-safety-hooks.md && echo "PASS: guard-git docs exist"
test -f docs/reference/branch-protection-rules.md && echo "PASS: branch protection doc exists"
test -f workflow-templates/release-branch.yml && echo "PASS: release-branch workflow exists"

# P2
ls scripts/ | wc -l | xargs -I{} test {} -gt 1 && echo "PASS: scripts/ has content"
test -f docs/how-to/fix-bug-flow.md && echo "PASS: fix-bug flow docs exist"
test -f docs/reference/agent-context-files.md && echo "PASS: agent-context doc exists"
test -f specs/state.yaml && echo "PASS: specs/ exists"
test -f .github/workflows/ci.yml && echo "PASS: dogfood CI exists"

# P3
test -f scripts/rollup-dora.sh && echo "PASS: DORA rollup exists"
grep -q 'Preflight' templates/readmes/template-README.md && echo "PASS: README has Preflight"
grep -q 'release-branch' docs/tutorials/new-project-quickstart.md && echo "PASS: quickstart has release-branch"
```
