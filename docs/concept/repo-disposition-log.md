---
type: Concept
title: Repo Disposition Log
description: Decision history for the disposition of danielvm-git portfolio repos — which were archived, merged, or kept standalone.
tags: [portfolio, repos, decisions, archive]
timestamp: 2026-07-13
provenance: docs/explanation/repo-disposition-log.md
story: e01s02
---

# Repo Disposition Log

## Overview

This document records the disposition decisions for danielvm-git portfolio repos. Append entries here, never overwrite — this is a decision history, not a live status board.

## 2026-07

| Repo | Decision | Reason |
|------|----------|--------|
| `skill-method-manager` | already archived (repo's own ARCHIVED.md, 2026-07-01) | superseded by bigpowers |
| `clean-install-guide` | already archived (repo's own ARCHIVED.md, 2026-07-01) | superseded by big-token-saver (bts) |
| `big-kickass-readme` | merge → `templates/readmes/`, then archive original | pure templates, no logic, belongs in the reference repo |
| `semantic-release-baby` | unresolved — content unconfirmed | pending manual check |
| `dev-checklist` | keep standalone | real installable CLI (`stack-check`); `.github/scripts/audit-workflows.sh` should call it |
| `brand_identity_danielvm` | keep standalone | different domain (brand/design tokens, not engineering) |
