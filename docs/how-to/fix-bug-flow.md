---
type: How-to
title: Fix-or-Log — Handle Discovered Defects in Any Repo
description: The fix-or-log ladder for handling red gates, bugs, and defects discovered during development.
tags: [bug-fix, workflow, tdd, quality]
timestamp: 2026-07-13
provenance: docs/how-to/fix-bug-flow.md
---

# Fix-or-Log — Handle Discovered Defects

## Overview

Every repo following bigpowers uses the fix-or-log ladder. When you hit a red gate (preflight fail, CI fail, compliance fail), do NOT continue — fix it. This how-to documents the three-level escalation ladder from quick-fix through full TDD cycle to logging.

## Before you start

- You are working in a bigpowers-managed repo
- A gate (preflight, CI, compliance) has turned red
- You have `git` access to commit fixes

## Step-by-step guide

### 1. Quick-fix (first attempt)

For trivial, data-only, or single-file fixes.

**Guardrails:**
- No logic changes
- No new dependencies
- No API/contract changes
- Change touches ≤ 3 files
- Fix is obvious (typo, dead code, missing config)

If any guardrail triggers → fall back to `fix-bug`.

```bash
git add <files>
git commit -m "fix(scope): description"
```

### 2. Fix-bug (second attempt)

For anything that needs investigation or TDD.

**Flow (5 steps):**
1. `investigate-bug` — create `specs/bugs/BUG-*.md` with RCA
2. `diagnose-root` — reproduce → isolate → hypothesize → verify
3. `develop-tdd` — red-green against bug file verify steps
4. `validate-fix` — re-run failing test, full suite, lint
5. `release-branch` — PR or solo land the fix

### 3. Log (last resort)

Only when reproduction is blocked after a good-faith attempt.

- Write a `specs/bugs/BUG-*.md` with what you tried
- Set `status: blocked` in the bug file
- Stop forward work until triaged

## Critical rules

- Never dismiss a reproducible gate failure as "pre-existing," "unrelated to this session," "not introduced by my changes," or "out of scope"
- Fix it or log it — don't narrate past it

## See also

- [Git Safety Hooks](guard-git-safety-hooks.md) — Block dangerous git operations in AI agents
- [Agent Context Files](../reference/agent-context-files.md) — AGENTS.md setup
