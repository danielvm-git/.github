---
type: reference
title: GitHub Actions version matrix
---

# GitHub Actions version matrix

Current latest versions of first-party `actions/*` for template updates. Verified 2026-07-12.

## Core actions

| Action | Latest | SHA | Notes |
|--------|--------|-----|-------|
| `actions/checkout` | `v7.0.0` | `9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0` | Used in all workflows |
| `actions/upload-artifact` | `v7.0.1` | `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` | CI artifact uploads |
| `actions/download-artifact` | `v8.0.1` | `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c` | Deploy job downloads |
| `actions/cache` | `v6.1.0` | `55cc8345863c7cc4c66a329aec7e433d2d1c52a9` | Dependency caching |

## Setup actions

| Action | Latest | SHA | Notes |
|--------|--------|-----|-------|
| `actions/setup-node` | `v6.4.0` | `48b55a011bda9f5d6aeb4c2d9c7362e8dae4041e` | Node.js projects |
| `actions/setup-python` | `v6.3.0` | `ece7cb06caefa5fff74198d8649806c4678c61a1` | Python projects |
| `actions/setup-go` | `v6.5.0` | `924ae3a1cded613372ab5595356fb5720e22ba16` | Go projects |
| `actions/setup-java` | `v5.5.0` | `0f481fcb613427c0f801b606911222b5b6f3083a` | Java projects |
| `actions/setup-ruby` | `v1.1.3` | — | Ruby projects |

## Pages & deployment

| Action | Latest | SHA | Notes |
|--------|--------|-----|-------|
| `actions/upload-pages-artifact` | `v5.0.0` | — | Pages deployment |
| `actions/deploy-pages` | `v5.0.0` | — | Pages deployment |
| `actions/configure-pages` | `v6.0.0` | — | Pages configuration |
| `actions/create-github-app-token` | `v3.2.0` | `bcd2ba49218906704ab6c1aa796996da409d3eb1` | App tokens |

## Current template versions vs latest

| Action | Current in templates | Latest | Gap |
|--------|---------------------|--------|-----|
| `actions/checkout` | `v4` | `v7.0.0` | **3 major versions behind** |
| `actions/setup-node` | `v4` | `v6.4.0` | **2 major versions behind** |
| `actions/setup-python` | `v5` | `v6.3.0` | **1 major version behind** |
| `actions/setup-go` | `v5` | `v6.5.0` | **1 major version behind** |
| `actions/upload-artifact` | `v4` | `v7.0.1` | **3 major versions behind** |
| `actions/download-artifact` | `v4` | `v8.0.1` | **4 major versions behind** |
| `actions/upload-pages-artifact` | `v3`/`v4` | `v5.0.0` | **1-2 major versions behind** |
| `actions/deploy-pages` | `v4` | `v5.0.0` | **1 major version behind** |
| `actions/configure-pages` | `v5` | `v6.0.0` | **1 major version behind** |

## Pinning format

```yaml
# Version tag (readable, lower risk for first-party actions)
- uses: actions/checkout@v7

# Full SHA (required for third-party or high-risk actions)
- uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0  # v7.0.0
```

## When to update

- **Major version bump**: Check changelog for breaking changes before updating
- **Template updates**: Update all `workflow-templates/*.yml` files together
- **Per-repo updates**: Update individual repos as part of regular maintenance

## References

- [GitHub Actions releases](https://github.com/actions)
- [GitHub Actions changelogs](https://github.com/actions/release)
- `docs/explanation/github-actions-best-practices.md` for security guidance
