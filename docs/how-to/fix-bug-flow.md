---
type: how-to
title: fix-or-log — handle discovered defects in any repo
---

# fix-or-log — handle discovered defects

Every repo following bigpowers uses the fix-or-log ladder. When you hit a red gate (preflight fail, CI fail, compliance fail), do NOT continue — fix it.

## The ladder (always try in order)

### 1. `quick-fix`

For trivial, data-only, or single-file fixes.

**Guardrails:**
- No logic changes
- No new dependencies
- No API/contract changes
- Change touches ≤ 3 files
- Fix is obvious (typo, dead code, missing config)

If any guardrail triggers → fall back to `fix-bug`.

```bash
# Apply the fix, verify, commit
git add <files>
git commit -m "fix(scope): description"
```

### 2. `fix-bug`

For anything that needs investigation or TDD.

**Flow (5 steps):**
1. `investigate-bug` — create `specs/bugs/BUG-*.md` with RCA
2. `diagnose-root` — reproduce → isolate → hypothesize → verify
3. `develop-tdd` — red-green against bug file verify steps
4. `validate-fix` — re-run failing test, full suite, lint
5. `release-branch` — PR or solo land the fix

Track progress in `specs/state.yaml` under `bug_cycle`.

### 3. Log

Only when reproduction is blocked after a good-faith attempt.

- Write a `specs/bugs/BUG-*.md` with what you tried
- Set `status: blocked` in the bug file
- Stop forward work on the original task until triaged

## Never

> **Never dismiss a reproducible gate failure as:**
> - "pre-existing"
> - "unrelated to this session"
> - "not introduced by my changes"
> - "out of scope"

Any of these phrases trigger the banned-phrases rule (bigpowers P0). Fix it or log it — don't narrate past it.
