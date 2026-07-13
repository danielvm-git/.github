# Threat Model: e01s05 — Docs auto-generation and validation tooling

**Story:** e01s05 — Build auto-generation and validation tooling
**Epic:** e01 — Refactor docs to Good Docs + OKF
**Date:** 2026-07-13
**Assessor:** build-epic Step 0 (security-review skill)
**Status:** PASS — No HIGH findings

## 1. Scope Resolution

**Diff base:** `feat/e01s05-docs-tooling` (new branch from e01s01, no commits yet)
**Planned changes:**
- `scripts/generate-doc-indexes.sh` — reads .md frontmatter, writes index.md files
- `scripts/validate-docs.sh` — reads .md files, checks frontmatter, line counts, file existence
- Potential CI / pre-commit hook wiring

**Languages:** Bash, YAML
**Risk surface:** File system I/O (read/write), shell globbing over untrusted filenames

## 2. Context Research

Existing security patterns in this repo:
- `guard-git` hooks block dangerous git operations (CONVENTIONS.md)
- Templates use `concurrency` groups and `timeout-minutes` in GitHub Actions
- All workflow templates pass `yamllint` validation
- No secrets stored in repo — deploy tokens are GitHub Actions secrets per repo

## 3. Vulnerability Assessment

### 3.1 Command injection via filenames (CWE-78)

| Vector | Severity | Confidence | Rationale |
|--------|----------|------------|-----------|
| Filenames with spaces/special chars passed unquoted to `grep`, `sed`, `awk` | MEDIUM | 7/10 | Bash loops over `find ... -name '*.md'` results; if a filename contains `$(...)` or backticks and is interpolated in a shell expression without quoting, injection is possible. |
| `title:` or `description:` fields in frontmatter passed to shell | MEDIUM | 5/10 | If scripts extract frontmatter values via `sed`/`awk` and pass them unsanitized to a shell expression, injection is possible. |

**Mitigation:** Scripts will use `while IFS= read -r file` pattern (safe), and frontmatter extraction via `sed`/`grep` with output consumed as data, not eval. No `eval` or `$(...)` interpolation of extracted values.

### 3.2 Path traversal (CWE-22)

| Vector | Severity | Confidence | Rationale |
|--------|----------|------------|-----------|
| Script writes to `docs/*/index.md` based on scanned directory names | LOW | 3/10 | Directory names are hardcoded Good Docs folder types (`concept/`, `how-to/`, etc.). No user-controlled path components. |

**Mitigation:** Directories are scanned with `find docs/* -maxdepth 0 -type d` — only immediate subdirectories. No path traversal risk.

### 3.3 Unvalidated YAML frontmatter (CWE-20)

| Vector | Severity | Confidence | Rationale |
|--------|----------|------------|-----------|
| Scripts parse YAML frontmatter with `sed`/`awk` — no YAML parser | LOW | 2/10 | Bash regex extraction is inherently limited; malformed frontmatter causes silent omission rather than injection. |

**Mitigation:** `validate-docs.sh` checks for `type:` field presence and value, but doesn't parse deeply. Malformed frontmatter causes validation failure (desired behavior) or index omission (low impact).

### 3.4 Overwrite of index.md (CWE-668)

| Vector | Severity | Confidence | Rationale |
|--------|----------|------------|-----------|
| `generate-doc-indexes.sh` overwrites index.md in every docs/ subfolder | LOW | 1/10 | Index files are auto-generated artifacts; idempotent by design. Safe to regenerate. |

**Mitigation:** Script creates index.md from scratch each run. No merging of user content — the index is derived data only.

### 3.5 Pre-commit hook / CI privilege escalation

| Vector | Severity | Confidence | Rationale |
|--------|----------|------------|-----------|
| Scripts run in pre-commit or CI context | LOW | 2/10 | Scripts read/write only within `docs/`. No network access, no secret access, no elevated permissions. |

**Mitigation:** Scripts are stateless — no tokens, no API calls, no external resources.

## 4. False-Positive Filtering

| Exclusion | Rationale |
|-----------|-----------|
| `scripts/lib/` does not exist (no shared libs) | Not applicable to scope |
| No SQL, no network, no crypto in scope | Scripts are pure file-system operations |
| No user input reachable from HTTP or CLI args | No argument parsing — hardcoded paths |
| `co-authored-by:` is handled by pre-commit hook, not scripts | Out of scope for security model |

## 5. Report Summary

| # | Category | Severity | Confidence | Verdict |
|---|----------|----------|------------|---------|
| 3.1 | Command injection (unquoted filenames) | MEDIUM | 7/10 | **Watch** — requires disciplined quoting in script implementation |
| 3.2 | Path traversal | LOW | 3/10 | **Accept** — no user-controlled input |
| 3.3 | Unvalidated frontmatter | LOW | 2/10 | **Accept** — low impact, caught by validation |
| 3.4 | Index file overwrite | LOW | 1/10 | **Accept** — by design |
| 3.5 | CI privilege escalation | LOW | 2/10 | **Accept** — no sensitive operations |

**Overall verdict: PASS** — No HIGH findings at ≥8 confidence.

**Security requirements for implementation:**
1. All shell loops must use `while IFS= read -r file` pattern (not `for file in $(find ...)`)
2. All variable expansions must be double-quoted: `"$file"`, `"$line"`
3. No `eval` or shell interpolation of extracted frontmatter values
4. Scripts exit non-zero on any error (`set -e` or explicit error handling)
