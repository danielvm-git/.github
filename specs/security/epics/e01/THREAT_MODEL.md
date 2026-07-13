# Threat Model: Epic e01 — Docs Refactor

**Epic:** e01-docs-refactor
**Story:** e01s01 (Bootstrap infrastructure)
**Date:** 2026-07-13
**Author:** security-review skill (build-epic step 0)

## Scope

e01s01 creates structural foundation for the Good Docs + OKF refactor. All changes are filesystem operations and markdown text edits with zero code execution paths:

| Operation | Surface |
|-----------|---------|
| `mkdir -p docs/{concept,how-to,...}` | Directory creation — no execution surface |
| Write `docs/index.md`, `docs/log.md` | Static markdown — no scripts, no includes |
| Write placeholder `index.md` in 9 subfolders | Static markdown — no scripts, no includes |
| `mv docs/tutorials/* docs/tutorial/` | File rename — no execution surface |
| `rm -rf docs/compose/` | Directory removal — no execution surface |
| `find docs -type d -empty -delete` | Empty dir cleanup — no execution surface |
| Text edit on `AGENTS.md` line 62 | String replace in static markdown — no execution surface |
| Check `CONVENTIONS.md` for Diátaxis (grep) | Read-only — no changes expected |

## Vulnerability Categories

### 1. Injection (SQLi, XSS, SSRF, Command Injection)

**Risk: NONE.** No user input reaches any sink. All operations are hardcoded mkdir/mv/rm/echo commands. No SQL, no HTML rendering, no network requests, no shell parameter expansion from untrusted sources.

### 2. Authentication / Authorization Bypass

**Risk: NONE.** No auth changes. No permission model changes. No new access controls introduced or modified.

### 3. Secrets / Credential Exposure

**Risk: NONE.** No secrets created, modified, or exposed. The markdown content added is purely structural (folder taxonomy, index placeholders).

### 4. Data Integrity / Accidental Data Loss

**Risk: LOW (P3).** The `rm -rf docs/compose/` and `mv docs/tutorials/*` operations could lose content if executed incorrectly. Mitigations:

- `docs/compose/` contains `reports/consolidated-ci-cd-templates.md` — content is referenced in epic.yaml for e01s02 migration. The file exists on disk at the time of execution; git history preserves it regardless.
- `docs/tutorials/` rename is an `mv` then `rmdir` — atomic within the same filesystem, so no copy-then-delete risk.
- All operations run in a git-tracked repo — `git checkout` can restore any mistakenly deleted content.

### 5. Path Traversal

**Risk: NONE.** All paths are hardcoded relative paths under `docs/`. No user-supplied path input. No symlink following concerns (operations use physical paths).

### 6. Supply Chain / Dependency Confusion

**Risk: NONE.** No new dependencies introduced. No package manager operations. No external library imports.

### 7. Unsafe Deserialization

**Risk: NONE.** No serialization/deserialization occurs. Markdown files are plain text, not parsed programmatically.

### 8. Template Injection

**Risk: NONE.** Markdown files are static content, not templates. No template engine involved.

## Risk Assessment Summary

| Category | Risk Level | Confidence |
|----------|-----------|------------|
| Injection | NONE | 10/10 |
| Auth bypass | NONE | 10/10 |
| Secrets exposure | NONE | 10/10 |
| Data integrity | LOW (P3) | 9/10 |
| Path traversal | NONE | 10/10 |
| Supply chain | NONE | 10/10 |
| Deserialization | NONE | 10/10 |
| Template injection | NONE | 10/10 |

**Overall Risk: LOW (P3)** — No code execution surface. Sole concern is accidental file loss during mv/rm operations, fully mitigated by git version control and the zero-dependency, hardcoded-path nature of all operations.

## Mitigation Guidance

1. **Pre-execution safeguard:** Run `git status` to confirm clean working tree before starting file operations.
2. **Incremental commits:** Commit after structural changes (tasks 1-7) separately from content edits (task 8) to enable targeted rollback.
3. **Verification gates:** Each task has a verify command (shell one-liner). Run all verifications before advancing.
4. **compose/ content preservation:** The epic.yaml for e01s02 explicitly references the file content to be migrated. Git history is the ultimate backup.

## Verdict

**PASS** — No blocking security findings. Proceed to Step 1.
