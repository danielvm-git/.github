# Plan: Wire Global MCP Servers to All IDEs/CLIs

**Date:** 2026-07-12
**Status:** DRAFT — awaiting approval

---

## 1. Current State Audit

| Tool | bigbase | context7 | sqz | sequential-thinking |
|------|:-------:|:--------:|:---:|:-------------------:|
| Claude Code | ❌ | ✅ HTTP | ✅ stdio | ❌ |
| Pi Agent | ✅ HTTP | ❌ | ❌ | ❌ |
| OpenCode (global) | ❌ | ✅ stdio | ✅ stdio | ✅ stdio |
| Antigravity CLI | ❌ | ✅ stdio | ✅ stdio | ✅ stdio |
| Antigravity IDE | ✅ serverUrl | ❌ | ❌ | ❌ |
| VS Code | ❌ | ❌ | ❌ | ❌ |
| Cursor | ❌ | ❌ | ❌ | ❌ |
| MiMoCode | ❌ (no config file) | ❌ | ❌ | ❌ |

**8 tools × 4 MCPs = 32 slots. Currently filled: 10. To wire: 22.**

---

## 2. Global MCP Server Definitions

| MCP | Transport | Stdio Command | Remote URL | Notes |
|-----|-----------|---------------|------------|-------|
| **bigbase** | Remote HTTP | `npx -y mcp-remote https://mcp.bigbase.click/mcp` | `https://mcp.bigbase.click/mcp` | No auth needed |
| **context7** | Remote HTTP | `npx -y @upstash/context7-mcp` | `https://mcp.context7.com/mcp` | Needs `CONTEXT7_API_KEY` header |
| **sqz** | Stdio | `sqz-mcp` (or `sqz-mcp --transport stdio`) | — | Binary at `~/.local/bin/sqz-mcp` |
| **sequential-thinking** | Stdio | `mcp-server-sequential-thinking` | — | Binary via npm global |

---

## 3. Per-Tool Config Entries

### 3.1 Claude Code — `~/.claude.json` → `mcpServers`

```jsonc
// ADD to existing mcpServers:
"bigbase": {
  "url": "https://mcp.bigbase.click/mcp"
},
"context7": {
  "type": "http",
  "url": "https://mcp.context7.com/mcp",
  "headers": {
    "CONTEXT7_API_KEY": "ctx7sk-48280f04-455a-48f6-a412-ed7bce04d55f"
  }
},
// sqz already exists ✅
"sequential-thinking": {
  "command": "mcp-server-sequential-thinking",
  "args": []
}
```

**Changes:** Add `bigbase`, `context7`, `sequential-thinking`. (sqz already present.)

---

### 3.2 Pi Agent — `~/.pi/agent/mcp.json` → `mcpServers`

```jsonc
// ADD to existing mcpServers:
"context7": {
  "url": "https://mcp.context7.com/mcp",
  "headers": {
    "CONTEXT7_API_KEY": "ctx7sk-48280f04-455a-48f6-a412-ed7bce04d55f"
  }
},
"sqz": {
  "command": "sqz-mcp",
  "args": ["--transport", "stdio"]
},
"sequential-thinking": {
  "command": "mcp-server-sequential-thinking",
  "args": []
}
// bigbase already exists ✅
```

**Changes:** Add `context7`, `sqz`, `sequential-thinking`. (bigbase already present.)

---

### 3.3 OpenCode (global) — `~/.config/opencode/opencode.json` → `mcp`

```jsonc
// ADD to existing mcp:
"bigbase": {
  "type": "remote",
  "url": "https://mcp.bigbase.click/mcp",
  "enabled": true
},
// context7 already exists ✅
// sqz already exists ✅
// sequential-thinking already exists ✅
```

**Changes:** Add `bigbase`. (context7, sqz, sequential-thinking already present.)

---

### 3.4 MiMoCode (global) — `~/.config/mimocode/mimocode.json` → `mcp`

**File does not exist yet — create it.**

```json
{
  "$schema": "https://mimo.xiaomi.com/mimocode/config.json",
  "mcp": {
    "bigbase": {
      "type": "remote",
      "url": "https://mcp.bigbase.click/mcp",
      "enabled": true
    },
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "enabled": true,
      "headers": {
        "CONTEXT7_API_KEY": "ctx7sk-48280f04-455a-48f6-a412-ed7bce04d55f"
      }
    },
    "sqz": {
      "type": "local",
      "command": ["sqz-mcp", "--transport", "stdio"],
      "enabled": true
    },
    "sequential-thinking": {
      "type": "local",
      "command": ["mcp-server-sequential-thinking"],
      "enabled": true
    }
  }
}
```

**Changes:** Create file with all 4 global MCPs.

---

### 3.5 Antigravity CLI — `~/.gemini/settings.json` → `mcpServers`

```jsonc
// ADD to existing mcpServers:
"bigbase": {
  "url": "https://mcp.bigbase.click/mcp"
},
// context7 already exists ✅
// sqz already exists ✅
// sequential-thinking already exists ✅
```

**Changes:** Add `bigbase`. (context7, sqz, sequential-thinking already present.)

---

### 3.6 Antigravity IDE — `~/.gemini/antigravity-ide/mcp_config.json` → `mcpServers`

```jsonc
// ADD to existing mcpServers:
"context7": {
  "serverUrl": "https://mcp.context7.com/mcp",
  "headers": {
    "CONTEXT7_API_KEY": "ctx7sk-48280f04-455a-48f6-a412-ed7bce04d55f"
  }
},
"sqz": {
  "command": "sqz-mcp",
  "args": ["--transport", "stdio"]
},
"sequential-thinking": {
  "command": "mcp-server-sequential-thinking",
  "args": []
}
// bigbase already exists ✅
```

**Changes:** Add `context7`, `sqz`, `sequential-thinking`. (bigbase already present.)

---

### 3.7 VS Code — `~/Library/Application Support/Code/User/settings.json` → `mcp.servers`

**File does not exist yet — create it.**

```json
{
  "mcp": {
    "servers": {
      "bigbase": {
        "url": "https://mcp.bigbase.click/mcp"
      },
      "context7": {
        "type": "http",
        "url": "https://mcp.context7.com/mcp",
        "headers": {
          "CONTEXT7_API_KEY": "ctx7sk-48280f04-455a-48f6-a412-ed7bce04d55f"
        }
      },
      "sqz": {
        "command": "sqz-mcp",
        "args": ["--transport", "stdio"]
      },
      "sequential-thinking": {
        "command": "mcp-server-sequential-thinking",
        "args": []
      }
    }
  }
}
```

**Changes:** Create settings.json with all 4 global MCPs under `mcp.servers`.

---

### 3.8 Cursor — `~/Library/Application Support/Cursor/User/settings.json`

**Existing file has 5 unrelated keys. Add `mcp` block.**

```jsonc
// ADD to existing settings:
"mcp": {
  "servers": {
    "bigbase": {
      "url": "https://mcp.bigbase.click/mcp"
    },
    "context7": {
      "type": "http",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "ctx7sk-48280f04-455a-48f6-a412-ed7bce04d55f"
      }
    },
    "sqz": {
      "command": "sqz-mcp",
      "args": ["--transport", "stdio"]
    },
    "sequential-thinking": {
      "command": "mcp-server-sequential-thinking",
      "args": []
    }
  }
}
```

**Changes:** Merge `mcp` block into existing settings.json.

---

## 4. Execution Plan

| Step | Action | Risk | Files Modified |
|------|--------|------|----------------|
| **1** | Back up all config files | None | — |
| **2** | Wire Claude Code: add bigbase + context7 + sequential-thinking to `~/.claude.json` | Low — additive only | `~/.claude.json` |
| **3** | Wire Pi Agent: add context7 + sqz + sequential-thinking to `~/.pi/agent/mcp.json` | Low — additive only | `~/.pi/agent/mcp.json` |
| **4** | Wire OpenCode: add bigbase to `~/.config/opencode/opencode.json` | Low — additive only | `~/.config/opencode/opencode.json` |
| **5** | Wire Antigravity CLI: add bigbase to `~/.gemini/settings.json` | Low — additive only | `~/.gemini/settings.json` |
| **6** | Wire Antigravity IDE: add context7 + sqz + sequential-thinking to `~/.gemini/antigravity-ide/mcp_config.json` | Low — additive only | `~/.gemini/antigravity-ide/mcp_config.json` |
| **7** | Wire MiMoCode: create `~/.config/mimocode/mimocode.json` with all 4 | Low — new file | `~/.config/mimocode/mimocode.json` |
| **8** | Wire VS Code: create `~/Library/Application Support/Code/User/settings.json` with `mcp` block | Medium — new file, VS Code format may need validation | `~/Library/Application Support/Code/User/settings.json` |
| **9** | Wire Cursor: merge `mcp` into existing `~/Library/Application Support/Cursor/User/settings.json` | Medium — editing existing settings | `~/Library/Application Support/Cursor/User/settings.json` |
| **10** | Verify each tool can see its MCP servers (restart/reconnect) | — | — |

---

## 5. Validation

After wiring, verify each tool by:

1. **Claude Code:** `claude mcp list` — should show all 4 global MCPs
2. **Pi Agent:** `pi mcp list` or check MCP status on startup
3. **OpenCode:** `opencode mcp list` or check startup banner
4. **MiMoCode:** Start MiMoCode and check MCP status
5. **Antigravity CLI:** `gemini mcp list` (or equivalent)
6. **Antigravity IDE:** Open IDE → Settings → MCP Servers
7. **VS Code:** Open Command Palette → "MCP: List Servers" or check Output panel
8. **Cursor:** Open Settings → MCP section

---

## 6. Key Decisions Needed

| Decision | Options | Recommendation |
|----------|---------|----------------|
| **context7 transport** | HTTP (remote) vs stdio (npx local) | HTTP for tools that support it (Claude, Pi, VS Code, Cursor); stdio for others (OpenCode, MiMoCode, Antigravity) — matches existing patterns |
| **bigbase transport** | HTTP (remote) vs stdio (npx mcp-remote) | HTTP where supported; stdio fallback for tools needing it |
| **API key exposure** | Hardcode key in configs vs use env var | Hardcode for now (local-only files); migrate to env vars later |
| **VS Code settings.json** | Create minimal vs wait for VS Code to auto-create | Create now — file doesn't exist and VS Code won't create it |

---

## 7. Summary Matrix (Target State)

| Tool | bigbase | context7 | sqz | sequential-thinking |
|------|:-------:|:--------:|:---:|:-------------------:|
| Claude Code | ✅ HTTP | ✅ HTTP | ✅ stdio | ✅ stdio |
| Pi Agent | ✅ HTTP | ✅ HTTP | ✅ stdio | ✅ stdio |
| OpenCode | ✅ remote | ✅ stdio | ✅ stdio | ✅ stdio |
| MiMoCode | ✅ remote | ✅ remote | ✅ stdio | ✅ stdio |
| Antigravity CLI | ✅ SSE | ✅ stdio | ✅ stdio | ✅ stdio |
| Antigravity IDE | ✅ serverUrl | ✅ HTTP | ✅ stdio | ✅ stdio |
| VS Code | ✅ HTTP | ✅ HTTP | ✅ stdio | ✅ stdio |
| Cursor | ✅ HTTP | ✅ HTTP | ✅ stdio | ✅ stdio |

**Target: 32/32 slots filled.**
