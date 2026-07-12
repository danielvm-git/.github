---
type: reference
title: MCP configuration matrix — all tools
---

# MCP configuration matrix

Cross-tool reference for wiring Model Context Protocol (MCP) servers into every supported AI coding agent. One doc, all formats, copy-paste ready.

## Quick decision: global vs per-project

| MCP | Scope | Why |
|-----|-------|-----|
| `bigbase` | Global | Same endpoint everywhere, no secrets |
| `context7` | Global | Library docs are universal |
| `sqz` | Global | Token compression useful everywhere |
| `sequential-thinking` | Global | Pure reasoning, no project context |
| `ctxo` | Per-project | Code intelligence needs project-local index |
| `seal` | Per-project | Security/compliance is project-specific |
| `filesystem` | Per-project | Allowed paths differ per project |

## Config format matrix

| Tool | Project file | Global file | Top key | Stdio format | HTTP format | Env vars |
|------|-------------|-------------|---------|--------------|-------------|----------|
| **Claude Code** | `.mcp.json` | `~/.claude.json` | `mcpServers` | `command` + `args` | `type: "http"` + `url` | `$VAR` / `${VAR}` |
| **VS Code / Cursor** | `.vscode/mcp.json` | user profile `mcp.json` | `servers` | `command` + `args` | `type: "http"` + `url` | N/A (use `env`) |
| **Antigravity CLI** | `.gemini/settings.json` | `~/.gemini/settings.json` | `mcpServers` | `command` + `args` | `url` (SSE) / `httpUrl` (HTTP) | `$VAR` / `${VAR}` |
| **Antigravity IDE** | `.gemini/antigravity-ide/mcp_config.json` | `~/.gemini/antigravity-ide/mcp_config.json` | `mcpServers` | `command` + `args` | `serverUrl` | N/A |
| **OpenCode** | `opencode.json` | `~/.config/opencode/opencode.json` | `mcp` | `type: "local"` + `command[]` | `type: "remote"` + `url` | `{env:VAR}` |
| **MiMoCode** | `.mimocode/mimocode.json` | `~/.config/mimocode/mimocode.json` | `mcp` | `type: "local"` + `command[]` | `type: "remote"` + `url` | `{env:VAR}` |
| **Pi Agent** | `.pi/mcp.json` | `~/.pi/agent/mcp.json` | `mcpServers` | `command` + `args` | `url` | N/A |

### Key differences

- **Three top-level keys**: `mcpServers` (Claude, Antigravity, Pi), `servers` (VS Code), `mcp` (OpenCode, MiMoCode)
- **Two stdio formats**: `command`+`args` (Claude, VS Code, Antigravity, Pi) vs `type:"local"`+`command[]` array (OpenCode, MiMoCode)
- **HTTP URL keys**: `url` (most), `httpUrl` (Antigravity streamable HTTP), `serverUrl` (Antigravity IDE)
- **Env var syntax**: `$VAR`/`${VAR}` (Claude, Antigravity) vs `{env:VAR}` (OpenCode, MiMoCode)

## Per-tool config snippets

### Claude Code

**Global** (`~/.claude.json`, user scope):

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

**Per-project** (`.mcp.json`):

```json
{
  "mcpServers": {
    "ctxo": {
      "command": "npx",
      "args": ["-y", "@ctxo/cli"]
    },
    "sqz": {
      "command": "sqz-mcp",
      "args": []
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

**CLI shorthand:**

```bash
claude mcp add --transport http bigbase https://mcp.bigbase.click/mcp
claude mcp add --transport stdio ctxo -- npx -y @ctxo/cli
claude mcp add --transport http bigbase https://mcp.bigbase.click/mcp \
  --header "Authorization: Bearer $TOKEN"
```

**Auth:** `headers` object or `--header` flag. Full OAuth 2.0 supported for HTTP servers.

### VS Code / Cursor

**Per-workspace** (`.vscode/mcp.json`):

```json
{
  "servers": {
    "bigbase-mcp": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://mcp.bigbase.click/mcp"]
    },
    "ctxo": {
      "command": "npx",
      "args": ["-y", "@ctxo/cli"]
    },
    "sqz": {
      "command": "sqz-mcp",
      "args": []
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/project", "/tmp"]
    },
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "seal": {
      "command": "npx",
      "args": [
        "-y", "mcp-remote",
        "https://api-stage.35.253.75.95.nip.io/mcp",
        "--header", "X-API-Key: $SEAL_API_KEY"
      ]
    }
  }
}
```

**Note:** VS Code uses `servers` key, not `mcpServers`. Cursor reads the same `.vscode/mcp.json` format.

**Auth:** `headers` object in config, or `--header` flag via `mcp-remote` wrapper.

### Antigravity CLI (successor to Gemini CLI)

**Global** (`~/.gemini/settings.json`):

```json
{
  "mcpServers": {
    "bigbase": {
      "url": "https://mcp.bigbase.click/mcp"
    },
    "context7": {
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "$CONTEXT7_API_KEY"
      }
    }
  }
}
```

**Per-project** (`.gemini/settings.json`):

```json
{
  "mcpServers": {
    "ctxo": {
      "command": "npx",
      "args": ["-y", "@ctxo/cli"]
    },
    "sqz": {
      "command": "sqz-mcp",
      "args": []
    },
    "seal": {
      "command": "npx",
      "args": [
        "-y", "mcp-remote",
        "https://api-stage.35.253.75.95.nip.io/mcp",
        "--header", "X-API-Key: $SEAL_API_KEY"
      ]
    }
  }
}
```

**CLI shorthand:**

```bash
gemini mcp add --transport http bigbase https://mcp.bigbase.click/mcp
gemini mcp add ctxo -- npx -y @ctxo/cli
gemini mcp add --transport http --header "X-API-Key: $KEY" seal https://api-stage.35.253.75.95.nip.io/mcp
```

**Auth:** `headers` object, `--header` flag, or full OAuth 2.0 with `authProviderType`.

**Transport selection:** `command` → stdio, `url` → SSE, `httpUrl` → streamable HTTP.

### Antigravity IDE

**Global** (`~/.gemini/antigravity-ide/mcp_config.json`):

```json
{
  "mcpServers": {
    "bigbase": {
      "serverUrl": "https://mcp.bigbase.click/mcp"
    }
  }
}
```

**Note:** Uses `serverUrl` (not `url`) and is a stripped-down config compared to Antigravity CLI.

### OpenCode

**Global** (`~/.config/opencode/opencode.json`):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "bigbase": {
      "type": "remote",
      "url": "https://mcp.bigbase.click/mcp",
      "enabled": true
    },
    "ctxo": {
      "type": "local",
      "command": ["npx", "-y", "@ctxo/cli"],
      "enabled": true
    },
    "sqz": {
      "type": "local",
      "command": ["sqz-mcp"],
      "enabled": true
    },
    "context7": {
      "type": "local",
      "command": ["npx", "-y", "@upstash/context7-mcp"],
      "enabled": true
    },
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/path/to/project", "/tmp"],
      "enabled": true
    },
    "sequential-thinking": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-sequential-thinking"],
      "enabled": true
    },
    "seal": {
      "type": "local",
      "command": ["npx", "-y", "mcp-remote", "https://api-stage.35.253.75.95.nip.io/mcp", "--header", "X-API-Key: ${env:SEAL_API_KEY}"],
      "enabled": true
    }
  }
}
```

**Key differences from Claude/Antigravity:**
- Top key is `mcp`, not `mcpServers`
- Stdio uses `type: "local"` + `command` as an array (not `command`+`args`)
- Remote uses `type: "remote"` + `url`
- Env vars in strings use `{env:VAR}` syntax
- `enabled` flag to toggle servers without removing config

**Auth:** `headers` object for remote, `{env:VAR}` for secrets. OAuth supported.

### MiMoCode

**Global** (`~/.config/mimocode/mimocode.json`):

```json
{
  "$schema": "https://mimo.xiaomi.com/mimocode/config.json",
  "mcp": {
    "bigbase": {
      "type": "remote",
      "url": "https://mcp.bigbase.click/mcp"
    },
    "ctxo": {
      "type": "local",
      "command": ["npx", "-y", "@ctxo/cli"]
    },
    "sqz": {
      "type": "local",
      "command": ["sqz-mcp"]
    },
    "context7": {
      "type": "local",
      "command": ["npx", "-y", "@upstash/context7-mcp"]
    }
  }
}
```

**Per-project** (`.mimocode/mimocode.json`):

```json
{
  "$schema": "https://mimo.xiaomi.com/mimocode/config.json",
  "mcp": {
    "seal": {
      "type": "local",
      "command": ["npx", "-y", "mcp-remote", "https://api-stage.35.253.75.95.nip.io/mcp", "--header", "X-API-Key: ${env:SEAL_API_KEY}"]
    },
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "${env:PWD}", "/tmp"]
    }
  }
}
```

**Same format as OpenCode** (MiMoCode is a fork). Same `mcp` key, `type: "local"`/`"remote"`, `{env:VAR}` syntax.

### Pi Agent

**Global** (`~/.pi/agent/mcp.json`):

```json
{
  "mcpServers": {
    "bigbase": {
      "url": "https://mcp.bigbase.click/mcp",
      "directTools": true
    }
  }
}
```

**Per-project** (`.pi/mcp.json`):

```json
{
  "mcpServers": {
    "bigbase": {
      "url": "https://mcp.bigbase.click/mcp",
      "headers": {
        "Authorization": "Bearer $TOKEN"
      }
    }
  }
}
```

**Note:** Pi uses `mcpServers` key and `url` for remote servers. `directTools: true` exposes tools without confirmation prompts.

## Server-specific notes

### bigbase / bigbase-mcp

These are the same server, different names. `bigbase` uses native HTTP transport. `bigbase-mcp` wraps via `npx mcp-remote`. Prefer `bigbase` when the tool supports native HTTP.

| Tool | Use name | Why |
|------|----------|-----|
| Claude Code | `bigbase` | Native `type: "http"` support |
| VS Code / Cursor | `bigbase-mcp` | No native HTTP; needs `mcp-remote` wrapper |
| Antigravity CLI | `bigbase` | Native `url` support |
| OpenCode / MiMoCode | `bigbase` | `type: "remote"` with `url` |
| Pi | `bigbase` | `url` field |

### seal

Requires API key auth via `mcp-remote` `--header` flag (not JSON headers) for tools that don't support native HTTP headers.

```bash
# The --header flag approach works everywhere:
npx -y mcp-remote https://api-stage.35.253.75.95.nip.io/mcp \
  --header "X-API-Key: $SEAL_API_KEY"
```

### ctxo

Requires `npx -y @ctxo/cli`. Tool names use `file::name::kind` format for symbol IDs. Run `ctxo index` in the project root before first use.

### context7

Two options:
1. **Remote** (no API key): `"url": "https://mcp.context7.com/mcp"` — rate-limited
2. **With API key**: `"headers": { "CONTEXT7_API_KEY": "ctx7sk-..." }` — higher limits

### sqz

Requires `sqz-mcp` binary installed globally (`npm install -g sqz-mcp`). Exposes `sqz_read_file`, `sqz_grep`, `sqz_list_dir` tools. Compression is lossy for ANSI codes — use `sqz_passthrough` when byte-exact output matters.

## Gotchas

1. **VS Code uses `servers`**, not `mcpServers` — the most common copy-paste error
2. **OpenCode/MiMoCode use `mcp`**, not `mcpServers` — third variant
3. **Claude Code requires `type: "http"`** with `url` — bare `url` without `type` is a config error
4. **Antigravity CLI distinguishes `url` (SSE) from `httpUrl` (streamable HTTP)** — pick the right one
5. **Antigravity IDE uses `serverUrl`** — different from Antigravity CLI's `url`
6. **seal auth needs `mcp-remote` `--header` flag** — JSON `headers` object doesn't work for seal's auth
7. **Don't use underscores in MCP server names** (Antigravity CLI) — the policy parser splits `mcp_server_tool` on the first underscore after `mcp_`, breaking wildcard rules
8. **filesystem server needs absolute paths** — use `${CLAUDE_PROJECT_DIR:-.}` (Claude) or `${env:PWD}` (OpenCode/MiMoCode) for project-relative paths

## Setup checklist for new projects

- [ ] Decide which MCPs are global vs per-project (see table above)
- [ ] Add global MCPs to tool-specific global config
- [ ] Add per-project MCPs to project config files
- [ ] Set environment variables for API keys (never hardcode)
- [ ] Test connectivity: run `/mcp` (Claude), `gemini mcp list` (Antigravity), or check tool panel (VS Code)
- [ ] For ctxo: run `ctxo index` in project root
- [ ] For seal: create exceptions for known false positives
