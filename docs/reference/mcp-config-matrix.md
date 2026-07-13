---
type: Reference
title: MCP Configuration Matrix — All Tools
description: Cross-tool reference for wiring Model Context Protocol (MCP) servers into every supported AI coding agent.
tags: [mcp, configuration, agents, reference]
timestamp: 2026-07-13
---

# MCP Configuration Matrix

## Overview

Cross-tool reference for wiring Model Context Protocol (MCP) servers into every supported AI coding agent. One document covering all formats — copy-paste ready.

## Quick decision: global vs per-project

| MCP | Scope | Why |
|-----|-------|-----|
| `bigbase` | Global | Same endpoint everywhere |
| `context7` | Global | Library docs are universal |
| `sqz` | Global | Token compression useful everywhere |
| `sequential-thinking` | Global | Pure reasoning |
| `ctxo` | Per-project | Code intelligence needs project-local index |
| `seal` | Per-project | Security/compliance is project-specific |
| `filesystem` | Per-project | Allowed paths differ per project |

## Config format matrix

| Tool | Project file | Global file | Top key |
|------|-------------|-------------|---------|
| **Claude Code** | `.mcp.json` | `~/.claude.json` | `mcpServers` |
| **VS Code / Cursor** | `.vscode/mcp.json` | user profile `mcp.json` | `servers` |
| **Antigravity CLI** | `.gemini/settings.json` | `~/.gemini/settings.json` | `mcpServers` |
| **Antigravity IDE** | `.gemini/antigravity-ide/mcp_config.json` | `~/.gemini/antigravity-ide/mcp_config.json` | `mcpServers` |
| **OpenCode** | `opencode.json` | `~/.config/opencode/opencode.json` | `mcp` |
| **MiMoCode** | `.mimocode/mimocode.json` | `~/.config/mimocode/mimocode.json` | `mcp` |
| **Pi Agent** | `.pi/mcp.json` | `~/.pi/agent/mcp.json` | `mcpServers` |

## Per-tool config snippets

### Claude Code — Global (`~/.claude.json`)

```json
{
  "projects": {
    "/path/to/project": {
      "mcpServers": {
        "bigbase": {
          "type": "http",
          "url": "https://mcp.bigbase.click/mcp"
        }
      }
    }
  }
}
```

### VS Code / Cursor — `.vscode/mcp.json`

```json
{
  "servers": {
    "bigbase-mcp": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.bigbase.click/mcp"]
    }
  }
}
```

### Antigravity CLI — Global (`~/.gemini/settings.json`)

```json
{
  "mcpServers": {
    "bigbase": {
      "url": "https://mcp.bigbase.click/mcp"
    }
  }
}
```

## Gotchas

1. **VS Code uses `servers`**, not `mcpServers` — most common copy-paste error
2. **OpenCode/MiMoCode use `mcp`**, not `mcpServers` — third variant
3. **Claude Code requires `type: "http"`** with `url` — bare `url` is a config error
4. **Antigravity CLI distinguishes `url` (SSE) from `httpUrl` (streamable HTTP)**
5. **Antigravity IDE uses `serverUrl`** — different from CLI's `url`
6. **Don't use underscores in MCP server names** (Antigravity CLI)
7. **filesystem server needs absolute paths**

## Setup checklist

- [ ] Decide which MCPs are global vs per-project
- [ ] Add global MCPs to tool-specific global config
- [ ] Add per-project MCPs to project config files
- [ ] Set environment variables for API keys (never hardcode)
- [ ] Test connectivity
- [ ] For ctxo: run `ctxo index` in project root

## References

- [GitHub Actions Best Practices](../concept/github-actions-best-practices.md)
