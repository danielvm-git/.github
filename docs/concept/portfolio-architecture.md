---
type: Concept
title: Portfolio Architecture — The 4-Layer Template System
description: How the danielvm-git portfolio is structured as a 4-layer template inheritance system — .github, bigpowers, brand identity, and individual repos.
tags: [architecture, portfolio, templates, layers]
timestamp: 2026-07-13
---

# Portfolio Architecture — The 4-Layer Template System

## Overview

The danielvm-git portfolio uses a layered architecture where shared infrastructure, methodology, and identity are maintained once and inherited by every repo. This eliminates duplication, ensures consistency across 28 repos, and lets individual projects focus on their unique code.

The system has four layers, each owned by a distinct repo. Lower layers provide foundations; upper layers consume and compose them.

## Glossary

| Term | Definition |
|------|-----------|
| **.github (this repo)** | Portfolio template layer providing CI/CD workflows, README templates, deploy actions, documentation standards, and agent context. Every repo inherits these templates. |
| **bigpowers** | The methodology system — a skills-based lifecycle for AI-assisted development. Installed per-project via `bigpowers setup`. |
| **Brand identity** | Visual identity assets: color tokens, typography scale, logo assets, spacing tokens. Source: [`danielvm-git/brand_identity_danielvm`](https://github.com/danielvm-git/brand_identity_danielvm). Mirrored in `.github` as `brand/`. |
| **Individual repo** | A project repo (e.g. `bigbase`, `my-awesome-service`) that inherits from the 3 layers above and contains its own product code. |
| **OKF** | Open Knowledge Framework — the frontmatter and metadata system used in all documentation. |
| **Good Docs Project** | The template taxonomy (concept, how-to, tutorial, reference, etc.) that shapes doc structure. |
| **Akita convention** | Naming rule: filenames must be unique enough that `grep -r` across the portfolio returns < 5 results. |
| **CI/CD template** | Pre-built GitHub Actions workflow files in `workflow-templates/` that repos copy into `.github/workflows/`. |

## The 4 layers

### Layer 1: .github (template layer)

**Repo**: `danielvm-git/.github`

This is the central template repository. It provides:

| Asset | Location | Inherited by |
|-------|----------|-------------|
| CI/CD workflow templates | `workflow-templates/` | All repos (via Actions tab) |
| Deploy action | `actions/bigbase-deploy/` | All repos (via workflow `uses:`) |
| README templates | `templates/readmes/` | New projects (via copy) |
| Documentation hub | `docs/` | All repos (via reference) |
| Branch protection baseline | `docs/reference/branch-protection-rules.md` | All repos (via policy) |
| Agent context convention | `AGENTS.md` | All repos (via `bigpowers setup`) |

### Layer 2: bigpowers (methodology)

**Repo**: `danielvm-git/bigpowers`

bigpowers provides the development lifecycle — skills, orchestration, and quality gates. It is installed per-project and provides:

| Skill | Purpose |
|-------|---------|
| `develop-tdd` | Test-driven development with red-green-refactor |
| `build-epic` | Full epic build cycle (8 steps) |
| `verify-work` | Multi-phase UAT gate |
| `audit-code` | Self-review checklist |
| `release-branch` | PR creation and merge workflow |
| `guard-git` | Git safety hooks for AI agents |

bigpowers conventions are documented in specs/ within each project. The `.github` repo extends these conventions but does not duplicate them.

### Layer 3: Brand identity

**Repo**: `danielvm-git/brand_identity_danielvm`

The canonical brand source. Mirrored in `.github/brand/` for easy access during project setup. Contains:

- **Colors**: Primary, secondary, accent palettes as CSS custom properties and SCSS variables
- **Typography**: Font stacks, size scale, line heights
- **Logos**: SVG and PNG variants (full, icon-only, monochrome)
- **Spacing**: 4px/8px base unit system
- **Tokens file**: `tokens.json` — machine-readable brand variables

### Layer 4: Individual repos

Each project repo (e.g. `bigbase`, `danielvm-git/.github` itself) contains:

- Product source code (owned by the project)
- `.github/workflows/` — CI/CD workflows (copied from layer 1 templates)
- `AGENTS.md` — Agent context (from `bigpowers setup`)
- `CLAUDE.md` → `AGENTS.md` — Symlinks (from `bigpowers setup`)
- `brand/` — Brand assets (copied from layer 3)
- `docs/` — Project-specific documentation (following Good Docs + OKF)

## What NOT to duplicate

| Item | Source of truth | Don't |
|------|----------------|-------|
| CI/CD templates | `danielvm-git/.github/workflow-templates/` | Don't maintain separate workflow files |
| Deploy action | `danielvm-git/.github/actions/bigbase-deploy/` | Don't write your own deploy step |
| Brand tokens | `danielvm-git/brand_identity_danielvm` | Don't define separate brand variables |
| Agent conventions | bigpowers via `AGENTS.md` | Don't create independent CLAUDE.md |
| Methodology docs | bigpowers `specs/` | Don't re-document skills in .github |
| Documentation structure | Good Docs + OKF (this bundle) | Don't invent your own taxonomy |
| Branch protection | `.github/docs/reference/branch-protection-rules.md` | Don't guess settings |
| Git safety | `guard-git` hooks via bigpowers | Don't write custom git-blocking hooks |

## How they connect

```text
┌──────────────────────────────────────────────────────────┐
│                      Layer 4                              │
│              Individual Project Repo                       │
│     (code, project docs, project-specific CI/CD)           │
│                                                           │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐   │
│  │ CI/CD from  │  │ Brand from   │  │ AGENTS.md     │   │
│  │ layer 1     │  │ layer 3      │  │ from layer 2  │   │
│  └─────────────┘  └──────────────┘  └───────────────┘   │
└──────────────────────────────────────────────────────────┘
                        ▲
                        │ inherits
┌──────────────────────────────────────────────────────────┐
│                      Layer 3                              │
│              danielvm-git/brand_identity_danielvm          │
│     (color tokens, typography, logos, spacing)            │
└──────────────────────────────────────────────────────────┘
                        ▲
                        │ mirrored in .github/brand/
┌──────────────────────────────────────────────────────────┐
│                      Layer 2                              │
│              danielvm-git/bigpowers                         │
│     (skills, orchestration, quality gates, git hooks)     │
└──────────────────────────────────────────────────────────┘
                        ▲
                        │ extended by .github conventions
┌──────────────────────────────────────────────────────────┐
│                      Layer 1                              │
│              danielvm-git/.github                           │
│     (CI/CD templates, deploy action, README templates,    │
│      documentation hub, brand mirror, agent context)      │
└──────────────────────────────────────────────────────────┘
```

When a new project starts:
1. GitHub inherits template workflows from `.github` (layer 1)
2. `bigpowers setup` seeds agent context and git hooks (layer 2)
3. Brand assets are copied from `.github/brand/` (layer 3 mirror)
4. The project writes its own code, referencing docs in `.github/docs/` (layer 1)

Changes to layers 1-3 automatically propagate to all 28 repos when they sync their templates. Individual repos should never maintain their own parallel versions of template-layer assets.
