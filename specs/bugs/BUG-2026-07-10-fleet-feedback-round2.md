---
bug_id: BUG-2026-07-10-fleet-feedback-round2
status: open
severity: high
scope: all
title: Fleet feedback round 2 — 12 bugs found across 9 field reports
discovered: field reports (9 GitHub issues in danielvm-git/.github, 2026-07-10)
created: 2026-07-10
---

## Summary

After the first fix-bug cycle closed 16 gaps in the .github template repo, 9 repos independently aligned themselves and filed field reports (issues #1–#9). Those reports surfaced 12 new bugs — some are quick fixes in .github, others require design decisions or changes in external repos (bigbase).

## Bug Inventory (12 items)

### P0 — Blockers

**1. bigbase-deploy-contract.md stale**
Still says `big-library`, `big-olive-books` authenticate with `BIGBASE_EMAIL`/`BIGBASE_PASSWORD`. Both have migrated to `BIGBASE_DEPLOY_TOKEN`. Also `big-bolao` migrated. Hits trust in the contract doc.
`→` verify: `grep -l "BIGBASE_EMAIL\|BIGBASE_PASSWORD" docs/reference/contracts/bigbase-deploy-contract.md` returns empty.

**2. Missing .properties.json for workflow templates**
Zero `.properties.json` files exist in `workflow-templates/`. GitHub's native Actions tab picker won't show curated names/labels without them. Quickstart step 2.4 calls for these explicitly. Hit by issues #2, #8, #9.
`→` verify: `ls workflow-templates/*.properties.json | wc -l` returns 11 (one per template).

**3. ci-python.yml + ci-go.yml missing concurrency**
All other 9 CI templates have `concurrency` groups. The two that lack it are Python and Go — likely the most-used stacks. Hit by issues #2, #7.
`→` verify: `grep -L 'concurrency:' workflow-templates/ci-python.yml workflow-templates/ci-go.yml` returns empty.

**4. ubuntu-latest in deploy templates**
`deploy-pages-mkdocs.yml` and `deploy-pages-starlight.yml` use `ubuntu-latest`. The learnings doc says "pin to ubuntu-22.04." Templates are the reference — they must dogfood. Hit by issue #7.
`→` verify: `grep 'ubuntu-latest' workflow-templates/deploy-pages-*.yml` returns empty.

**5. Branches: [main] too narrow in CI templates**
Templates trigger only on `[main]`. Real projects use `develop`, `master`, or custom branch names. Hit by issue #9.
`→` verify: CI templates include `[main, develop, master]` or equivalent breadth.

### P1 — High

**6. security-baseline.yml not callable**
Named like a reusable workflow but contains only comments. Can't `uses:` it. Every repo must copy-paste the 3 blocks manually — guarantees drift across 28 repos. Hit by issues #6, #7, #8, #9.
`→` verify: TBD — needs design decision (make it a real reusable workflow, rename it, or add a checker script).

**7. No migration guide for existing repos**
`new-project-quickstart.md` covers greenfield only. The 28 existing repos have no documented upgrade path. Every field report (#1, #4, #5, #8, #9) hit this independently. Cost: hours per repo × 28 repos.
`→` verify: `test -f docs/tutorials/align-existing-repo.md` passes.

**8. bigbase-deploy action missing passthrough_paths input**
`actions/bigbase-deploy/action.yml` doesn't accept `passthrough_paths`. big-bolao needs `["/api/version"]`, big-library needs `["/mcp"]` for their API/MCP routes. Both repos had to inline deploy manually instead of using the reusable action. Hit by issues #1, #9.
`→` verify: BLOCKED — requires change in `danielvm-git/bigbase` repo. Bug filed there.

**9. Missing scripts (audit, brand tokens, symlink checker)**
Three scripts requested across multiple field reports:
- `scripts/audit-workflows.sh` — portfolio-wide compliance scan (hit by #4, #6, #7, #9)
- `scripts/pull-brand-tokens.sh` — automate design token import from brand_identity_danielvm (hit by #2, #5)
- Symlink integrity CI checker — fails if CLAUDE.md/GEMINI.md are regular files (hit by #1, #4, #8)
`→` verify: each script exists and passes shellcheck.

### P2 — Medium

**10. README templates too narrow**
- No game engine / generic README (#6)
- All assume Vercel/Netlify, not BigBase (#8, #9)
- Greenfield-only, no migration path for existing READMEs (#4, #8)
- npm vs pnpm mismatch between templates and CI (#5)
`→` verify: new templates exist + existing ones updated.

**11. Missing templates batch**
- `.pre-commit-config.yaml` template (#4)
- CodeQL workflow templates — Python + JavaScript (#7)
- `ISSUE_TEMPLATE/` with real `bug_report.yml` + `feature_request.yml` (#6)
- `.gitignore` templates per stack (#1)
- `.releaserc.shared.json` (#6)
- `ci-python-uv.yml` variant (#7)
`→` verify: each template file exists.

**12. ci-vue-spa.yml duplicates bigbase-deploy action logic**
Has `# TODO: replace with: uses: danielvm-git/.github/actions/bigbase-deploy@<sha>` but the full deploy + health check is inlined. Projects copying the template get duplicated logic that can diverge. Hit by issue #7.
`→` verify: ci-vue-spa.yml uses the action or the TODO is resolved with explanation.

## Fix Approach

Work P0→P2. P0 items are mostly quick changes in .github files. P1 items involve design decisions or external deps. P2 items are additive (new files).

## References

- Field report issues: danielvm-git/.github#1 through #9
- Previous bug cycle: BUG-2026-07-10-template-gaps (16 items, closed)
- Audit: docs/reference/audit-history/2026-07-audit.md
