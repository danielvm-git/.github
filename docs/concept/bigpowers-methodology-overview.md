---
type: Concept
title: Bigpowers Methodology Overview
description: What bigpowers is, its 6-phase lifecycle, and how the .github reference repo should build on it rather than duplicate it.
tags: [bigpowers, methodology, architecture, lifecycle]
timestamp: 2026-07-13
provenance: docs/explanation/bigpowers-learnings.md
story: e01s02
---

# Bigpowers Methodology Overview

## Overview

`bigpowers` (`/Users/danielvm/Developer/bigpowers`) is the methodology engine behind essentially every repo in this portfolio — not a project among the 28, but the tool that shaped how each one was built. This document records what it actually does, so the `.github` reference repo builds on it instead of re-explaining or re-inventing pieces of it.

## Glossary

| Term | Definition |
|------|-----------|
| bigpowers | A prescriptive, spec-driven methodology for building software with AI coding agents, published as an npm package with 77 "skills" |
| Skill | A targeted instruction set for one phase of development (e.g., `develop-tdd`, `audit-code`, `verify-work`) |
| OKF | Open Knowledge Format — YAML frontmatter convention for documentation metadata |
| BCP | Business Complexity Points — sizing metric for work estimation |
| DORA | DevOps Research and Assessment — four key metrics for software delivery performance |
| WSJF | Weighted Shortest Job First — prioritization method for sequencing work |

## The 6-phase lifecycle

Every project seeded with bigpowers follows `orchestrate-project`:

1. **Discover** — `survey-context`, `research-first`, `elaborate-spec`
2. **Elaborate** — `model-domain`, `grill-me`, `define-language`, `deepen-architecture`
3. **Plan** — `scope-work`, `slice-tasks`, `plan-work` → `release-plan.yaml` with a BCP baseline
4. **Build** — per-story 8-step cycle: `survey-context` → `plan-work` → `kickoff-branch` → `develop-tdd` (RED/GREEN/REFACTOR) → `verify-work` → `audit-code` (≥94% quality gate) → `commit-message` → `release-branch`
5. **Verify** — `run-evals`, project-level `verify-work`
6. **Release** — `semantic-release` to the first `1.0.0` tag

State persists in `specs/state.yaml` across sessions so an agent can resume mid-story via `handoff.next_skill`.

## Parts worth reusing directly, not reinventing

**`specs/conventions-wiki/` — CONVENTIONS.md, decomposed.** The script that splits a single `CONVENTIONS.md` into one atomic file per `##` heading is exactly the "flat directory + `type:` frontmatter" pattern proposed for the `.github` reference repo's own `docs/`.

**`specs/metrics/*.okf.md` — a DORA pipeline already running.** Each story's metrics file tracks the four DORA keys (lead time, deployment frequency, change failure rate, time to restore) plus agent-specific telemetry. The `.github` repo's DX Core 4 metrics doc should frame itself as extending this pipeline.

**The risk-tier hard gates.** `always-green`, `no-direct-coding`, `traceability`, `no-generated-edits` are P0 (never violate). The `.github` repo doesn't need its own principles doc; it needs a pointer to these.

## Real bug found while researching

`seed-conventions`'s documented design calls for `CLAUDE.md` and `GEMINI.md` to be **symlinks** to one canonical `AGENTS.md`. File timestamps across several repos show they are not symlinks — they have diverging modification dates. At least 7 repos are affected. Fix tracked in a separate how-to document.

## What this means for the .github repo's scope

- **Don't build**: a competing principles/conventions doc, a competing metrics pipeline, a competing "how to structure a new project" guide
- **Do build**: the layer bigpowers doesn't touch — CI/CD templates, the `bigbase-deploy` action, GitHub Pages/Wiki guidance, and portfolio-wide rollup metrics

## References

- [Agent Context Files](../reference/agent-context-files.md) — AGENTS.md pattern
- [branch-protection-rules.md](../reference/branch-protection-rules.md) for branch protection setup
