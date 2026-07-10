---
bug_id: BUG-2026-07-10-p3-deferred
status: fixed
severity: medium
scope: all
title: Close 4 deferred P3 gaps — versioning, changelog, monorepo CI, test harness
discovered: design review issue #2
created: 2026-07-10
closed: 2026-07-10
---

## Summary

4 items deferred from the initial design review. All now implemented.

## Items closed

### 1. Template versioning
Every workflow template now has `# version: 1.0.0 — see workflow-templates/CHANGELOG.md` as its second line. The `scripts/audit-template-versions.sh` script scans all portfolio repos and reports version mismatches.

### 2. Template changelog
`workflow-templates/CHANGELOG.md` records the 1.0.0 baseline with all 16 templates listed. Future template changes append entries here.

### 3. Multi-stack CI
`workflow-templates/ci-monorepo.yml` — auto-detects Node, Python, Rust, Go, Shell per subdirectory using `if: hashFiles()`. Companion `.properties.json` for the GitHub Actions picker.

### 4. Test harness
`scripts/validate-templates.sh` — validates all 16 templates for:
- YAML syntax (yamllint, if installed)
- Required fields (name, on, permissions, concurrency, timeout-minutes, ubuntu-22.04, version)
- .properties.json companion file existence
- Ubuntu exemption for ci-swift.yml (needs macOS)

## Side fixes
- `ci-rust.yml` — added missing `concurrency` group
- `ci-static-site.yml` — added missing `concurrency` group
- `ci-go.yml` — already had concurrency (was fixed in round 2)

## Verify

→ verify:
```bash
# All 16 templates pass validation
bash scripts/validate-templates.sh && echo "PASS" || echo "FAIL"

# CHANGELOG exists
test -f workflow-templates/CHANGELOG.md && echo "PASS: CHANGELOG" || echo "FAIL"

# Monorepo CI exists
test -f workflow-templates/ci-monorepo.yml && echo "PASS: monorepo CI" || echo "FAIL"

# Version audit script exists
test -f scripts/audit-template-versions.sh && echo "PASS: audit script" || echo "FAIL"

# .properties.json parity
test $(ls workflow-templates/*.yml | wc -l) -eq $(ls workflow-templates/*.properties.json | wc -l) && echo "PASS: .properties parity" || echo "FAIL"
```
