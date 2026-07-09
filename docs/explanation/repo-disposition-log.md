---
type: explanation
title: Repo disposition log
---

# Repo disposition log

Append entries here, never overwrite — this is a decision history, not a live status board.

## 2026-07

| Repo | Decision | Reason |
|---|---|---|
| `skill-method-manager` | already archived (repo's own ARCHIVED.md, 2026-07-01) | superseded by bigpowers |
| `clean-install-guide` | already archived (repo's own ARCHIVED.md, 2026-07-01) | superseded by big-token-saver (bts) |
| `big-kickass-readme` | merge → `templates/readmes/`, then archive original | pure templates, no logic, belongs in the reference repo |
| `semantic-release-baby` | unresolved — content unconfirmed (not cloned locally, GitHub API rate-limited during review) | pending manual check |
| `dev-checklist` | keep standalone | real installable CLI (`stack-check`); `.github/scripts/audit-workflows.sh` should call it, not duplicate its checks |
| `brand_identity_danielvm` | keep standalone | different domain (brand/design tokens, not engineering); confirmed via GitHub API: "Brand identity, design tokens, and static preview for danielvm.net" |
