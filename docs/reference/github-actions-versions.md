---
type: reference
title: GitHub Actions version matrix
---

# GitHub Actions version matrix

Current latest versions of first-party `actions/*` and third-party pins for template updates. Verified 2026-07-25. Org templates pin to **commit SHAs** (with version comments), never floating major tags.

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

## Third-party (must SHA-pin)

| Action | Latest | SHA | Notes |
|--------|--------|-----|-------|
| `golangci/golangci-lint-action` | `v6.5.2` | `55c2c1448f86e01eaae002a5a3a9624417608d84` | Pin **commit** SHA (not annotated-tag object). Binary: `version: v1.64.8` — never `latest` |
| `astral-sh/setup-uv` | `v5.4.2` | `d4b2f3b6ecc6e67c4457f6d3e41ec42d3d0fcb86` | Python template |
| `dtolnay/rust-toolchain` | `stable` branch | `4cda84d5c5c54efe2404f9d843567869ab1699d4` | Monorepo; floating branch tip — re-resolve periodically |

## Pages & deployment

| Action | Latest | SHA | Notes |
|--------|--------|-----|-------|
| `actions/upload-pages-artifact` | `v5.0.0` | `fc324d3547104276b827a68afc52ff2a11cc49c9` | Pages deployment |
| `actions/deploy-pages` | `v5.0.0` | `cd2ce8fcbc39b97be8ca5fce6e763baed58fa128` | Pages deployment |
| `actions/configure-pages` | `v6.0.0` | — | Pages configuration |
| `actions/create-github-app-token` | `v3.2.0` | `bcd2ba49218906704ab6c1aa796996da409d3eb1` | App tokens |
| `danielvm-git/.github/actions/bigbase-deploy` | `v1` | `9c56ac10c629f3baa110ddb19136579e3c90d690` | Retag `v1` after `skip_health_check` lands; update SHA in deploy templates |

## Current template versions vs latest

| Action | Current in templates | Latest | Status |
|--------|---------------------|--------|--------|
| `actions/checkout` | SHA → `v7.0.0` | `v7.0.0` | Up to date |
| `actions/setup-node` | SHA → `v6.4.0` | `v6.4.0` | Up to date |
| `actions/setup-python` | SHA → `v6.3.0` | `v6.3.0` | Up to date |
| `actions/setup-go` | SHA → `v6.5.0` | `v6.5.0` | Up to date |
| `actions/upload-artifact` | SHA → `v7.0.1` | `v7.0.1` | Up to date |
| `actions/download-artifact` | SHA → `v8.0.1` | `v8.0.1` | Up to date |
| `actions/upload-pages-artifact` | SHA → `v5.0.0` | `v5.0.0` | Up to date |
| `actions/deploy-pages` | SHA → `v5.0.0` | `v5.0.0` | Up to date |
| `golangci/golangci-lint-action` | SHA → `v6.5.2` | `v6.5.2` | Up to date |
| `astral-sh/setup-uv` | SHA → `v5.4.2` | `v5.4.2` | Up to date |

## Pinning format

```yaml
# Org templates: full commit SHA + version comment (required)
- uses: actions/checkout@9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0  # v7.0.0

# Resolve: gh api repos/<owner>/<repo>/git/ref/tags/<tag>
# If object.type == tag (annotated), peel: gh api repos/.../git/tags/<sha> → .object.sha
```

## When to update

- **Major version bump**: Check changelog for breaking changes before updating
- **Template updates**: Update all `workflow-templates/*.yml` files together
- **Per-repo updates**: Update individual repos as part of regular maintenance

## References

- [GitHub Actions releases](https://github.com/actions)
- [GitHub Actions changelogs](https://github.com/actions/release)
- `docs/explanation/github-actions-best-practices.md` for security guidance
