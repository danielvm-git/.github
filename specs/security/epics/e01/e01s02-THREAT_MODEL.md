# e01s02 Threat Model — Content Conversion

**Story:** e01s02 — Refactor existing docs to Good Docs templates + OKF frontmatter
**Date:** 2026-07-13
**Assessor:** AI security review (build-epic Step 0)

## Scope

| Dimension | Scope |
|-----------|-------|
| Content edits | Adding/updating YAML frontmatter, restructuring markdown sections |
| File renames | `explanation/` → `concept/`, individual file renames for Akita compliance |
| File moves | `contabo-vps-api.md` from `reference/` to `api-reference/` |
| File consolidation | Merge `audit-history/*.md` into single `reference/audit-history.md` |
| New content | None — all content already exists in the worktree |

## Threat Categories

| Category | Relevant? | Risk | Rationale |
|----------|-----------|------|-----------|
| SQLi | No | None | No databases, no queries |
| XSS | No | None | Static markdown files, not served to users |
| SSRF | No | None | No outbound requests from this repo |
| Command injection | No | None | No shell execution in doc content |
| Auth bypass | No | None | No auth boundaries in doc files |
| Unsafe deserialization | No | None | No serialization in markdown |
| Path traversal | No | None | File renames are within `docs/` only |
| IDOR | No | None | No access control per doc |
| Crypto flaws | No | None | No crypto operations |
| Secrets exposure | Low | Low | Frontmatter may contain internal paths (e.g., `/Users/danielvm/Developer/`); review for production secrets |
| Template injection | No | None | No server-side template engine processes these files |
| NoSQLi | No | None | No database queries |

## Risk Assessment

**Overall: LOW** — all changes are content-restructuring within the `docs/` directory. No code execution, no network calls, no auth boundaries.

### Specific Findings

1. **Internal path exposure** (Low): Some docs contain absolute paths like `/Users/danielvm/Developer/`. These are acceptable for a private portfolio reference repo. Move to public? Re-assess.
2. **Frontmatter injection** (Negligible): YAML frontmatter is a static metadata struct with controlled keys (`type`, `title`, `description`, `tags`, `timestamp`). No user-supplied values enter frontmatter fields.
3. **Symlink integrity** (Low): `docs/` does not contain symlinks. No risk of symlink-follow during rename operations.

## Verification

```bash
# Verify no secrets in frontmatter
rg 'secret|password|token|key:\s+' docs/ --type md -i -l | grep -v -i 'reference\|contract\|audit' || echo "No unexpected secrets in docs"
```

## Conclusion

**PASS** — No high-confidence findings. Proceed with content conversion.
