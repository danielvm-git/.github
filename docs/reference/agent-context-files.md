---
type: Reference
title: Agent Context Files — AGENTS.md Pattern
description: How to set up and verify the canonical AGENTS.md pattern with symlinks for multi-agent tools.
tags: [agents, context, setup, symlinks]
timestamp: 2026-07-13
---

# Agent Context Files

## Overview

Every danielvm-git repo uses a single canonical agent context file with symlinks — not copies — for each agent tool. This prevents silent drift between files that should contain identical content.

## The pattern

```text
AGENTS.md          ← canonical source (one file)
CLAUDE.md  → AGENTS.md   (symlink)
GEMINI.md  → AGENTS.md   (symlink)
```

## Setup (new repo)

`bigpowers setup` handles this automatically via `seed-conventions`. Manual:

```bash
ln -sf AGENTS.md CLAUDE.md
ln -sf AGENTS.md GEMINI.md
```

## Verify (existing repo)

```bash
ls -la CLAUDE.md GEMINI.md
```

Good: `CLAUDE.md -> AGENTS.md`, `GEMINI.md -> AGENTS.md`
Bad (drift — fix immediately): independent files with different sizes/dates.

## Repair drifting repos

```bash
rm CLAUDE.md GEMINI.md
ln -sf AGENTS.md CLAUDE.md
ln -sf AGENTS.md GEMINI.md
```

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

## References

- [Conventions on agent file attribution](../../CONVENTIONS.md)
