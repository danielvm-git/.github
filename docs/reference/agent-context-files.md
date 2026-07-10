---
type: reference
title: Agent context files — AGENTS.md pattern
---

# Agent context files

Every danielvm-git repo uses a single canonical agent context file with symlinks — not copies — for each agent tool.

## The pattern

```
AGENTS.md          ← canonical source (one file)
CLAUDE.md  → AGENTS.md   (symlink)
GEMINI.md  → AGENTS.md   (symlink)
```

**Why symlinks, not copies:** Three independent files drift silently (see `docs/explanation/bigpowers-learnings.md` for the real bug found across 7 repos). A symlink guarantees all agents read the same content.

## Set up (new repo)

`bigpowers setup` handles this automatically via `seed-conventions`. If you're setting up manually:

```bash
ln -sf AGENTS.md CLAUDE.md
ln -sf AGENTS.md GEMINI.md
```

## Verify (existing repo)

```bash
# Should show symlink targets, not independent files
ls -la CLAUDE.md GEMINI.md

# Good output:
# CLAUDE.md -> AGENTS.md
# GEMINI.md -> AGENTS.md

# Bad output (drift — fix immediately):
# -rw-r--r-- 1 user staff 1234 Jul 1 CLAUDE.md
# -rw-r--r-- 1 user staff 1240 Jun 30 GEMINI.md
```

## Repair drifting repos

If the symlinks have become real files:

```bash
rm CLAUDE.md GEMINI.md
ln -sf AGENTS.md CLAUDE.md
ln -sf AGENTS.md GEMINI.md
```

Then verify with `ls -la` that both show `-> AGENTS.md`.

## Multi-agent tools supported

| Agent | File | Native support |
|-------|------|----------------|
| Claude Code | `CLAUDE.md` | ✅ |
| Cursor | `CLAUDE.md` via `.cursor/rules/` | ✅ (auto-generated) |
| Cline | `AGENTS.md` | ✅ native |
| Aider | `AGENTS.md` | ✅ native |
| OpenCode | `AGENTS.md` | ✅ native |
| Gemini CLI | `GEMINI.md` | ✅ |
| pi | `.pi/prompts/` | ✅ (auto-generated) |
