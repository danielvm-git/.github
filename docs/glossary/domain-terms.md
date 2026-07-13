---
type: Glossary
title: Domain Terms Glossary
description: Canonical definitions for domain terms used across the danielvm-git portfolio documentation.
tags: [glossary, terminology, domain, portfolio]
timestamp: 2026-07-13
story: e01s04
---

# Domain Terms Glossary

## Overview

This glossary records the canonical definition of every domain-specific term used in this documentation bundle. Terms are listed alphabetically.

| Term | Definition |
|------|-----------|
| **BCP** | Business Complexity Points — a relative sizing metric for work estimation, used in WSJF calculations and epic task planning. One BCP represents a small, well-understood unit of work (roughly 1-4 hours for a skilled practitioner). |
| **bigbase** | The deployment target for danielvm-git portfolio applications — a Contabo VPS running Coolify. bigbase provides Docker-based hosting with automatic SSL, health checks, and rollback support. |
| **bigpowers** | A prescriptive, spec-driven methodology for building software with AI coding agents, published as an npm package. Provides 77+ skills covering the full development lifecycle (plan, build, verify, release). |
| **Conventional Commits** | A specification for adding human and machine-readable meaning to commit messages (e.g., `feat:`, `fix:`, `docs:`). Used across the portfolio for automated versioning and changelog generation. |
| **Diátaxis** | A documentation framework that divides documentation into four types: tutorials, how-to guides, explanation, and reference. Formally deprecated in this portfolio in favor of the Good Docs Project taxonomy (July 2026). |
| **DORA** | DevOps Research and Assessment — a set of four key metrics for measuring software delivery performance: deployment frequency, lead time for changes, mean time to restore (MTTR), and change failure rate. |
| **Good Docs Project** | An open-source project that produces documentation templates organized by type (concept, how-to, tutorial, reference, api-reference, troubleshooting, release-notes, style-guide, glossary). Adopted as the body-structure standard for all portfolio documentation. |
| **guard-git** | A set of git hooks that block dangerous git operations (push, force push, reset --hard, clean, destructive checkouts) in AI agent sessions. Installed per-repo via `how-to/guard-git-safety-hooks.md`. |
| **OKF** | Open Knowledge Format — a YAML frontmatter convention for documentation metadata. Defines fields like `type`, `title`, `description`, `tags`, `timestamp`, `provenance`, and `story` for cross-repo discoverability. |
| **semantic-release** | An automated version management and package publishing tool that determines version bumps based on Conventional Commits. Standardized across all portfolio repos that publish packages. |
| **WSJF** | Weighted Shortest Job First — a prioritization method that divides Business Value, Time Criticality, and Risk Reduction/Opportunity Enablement by Job Size to produce a priority score. Used to sequence epics in the release plan. |
