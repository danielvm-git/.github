---
type: How-to
title: Install Git Safety Hooks Per Repo
description: How to install and verify guard-git hooks that block dangerous git operations in AI agent sessions.
tags: [git, hooks, safety, guard-git, agents]
timestamp: 2026-07-13
provenance: docs/how-to/git-safety-hooks.md
---

# Git Safety Hooks (Guard-Git)

## Overview

bigpowers ships `guard-git` hooks that block dangerous git operations in AI agent sessions and enforce commit discipline. This guide explains installation, verification, blocked vs. allowed operations, and emergency bypass.

## Before you start

- Repo is cloned and you have write access
- `bigpowers` is installed (or you can install hooks manually)

## Step-by-step guide

### 1. Installation via bigpowers (recommended)

```bash
bigpowers setup
```
Hooks are auto-linked for Claude Code, Cursor, Gemini CLI, and pi.

### 2. Manual installation

```bash
# Claude Code
mkdir -p .claude/hooks
cp node_modules/bigpowers/scripts/hooks/pre-tool-use.sh .claude/hooks/
```

### 3. Verify hooks are active

```bash
ls .claude/hooks/pre-tool-use.sh 2>/dev/null && echo "Claude Code: HOOKED" || echo "Claude Code: missing"
```

## What's blocked vs. allowed

| Operation | Blocked? |
|-----------|----------|
| `git push origin main` | 🔴 Blocked |
| `git push origin feature-branch` | 🟢 Allowed |
| `git push --force` | 🔴 Blocked |
| `git reset --hard` | 🔴 Blocked |
| `git branch -D main` | 🔴 Blocked |
| `git branch -d feat/done` | 🟢 Allowed |
| `git checkout .` | 🔴 Blocked |
| Non-Conventional Commit message | 🔴 Blocked |
| `Co-authored-by:` in commit | 🔴 Blocked (P1) |
| `git commit -F file` with attribution | 🔴 Blocked |

## Disabling (emergency only)

Set `GIT_BIGPOWERS_LAND=1` to bypass for intentional land operations (used by `scripts/land-branch.sh`).

## See also

- [Fix-or-Log Flow](fix-bug-flow.md) — Handle discovered defects
- [Agent Context Files](../reference/agent-context-files.md) — AGENTS.md setup
