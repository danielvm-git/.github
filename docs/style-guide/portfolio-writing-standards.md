---
type: Style Guide
title: Portfolio Writing Standards
description: Writing standards for the danielvm-git portfolio documentation — OKF frontmatter, Good Docs template sections, Akita naming, Ousterhout size caps, provenance links, and story tags.
tags: [style-guide, standards, writing, documentation, portfolio]
timestamp: 2026-07-13
story: e01s04
---

# Portfolio Writing Standards

## Overview

Every document in this portfolio follows three layers of convention:

1. **OKF v0.1** provides frontmatter metadata (type, title, description, tags, timestamp, provenance, story).
2. **Good Docs Project templates** provide body structure (concept, how-to, reference, etc.).
3. **bigpowers conventions** govern naming, size caps, provenance, and traceability.

This guide documents all three layers so contributors and AI agents produce consistent documentation.

---

## OKF Frontmatter Convention

Every `.md` file (except `index.md` and `log.md`) must begin with YAML frontmatter delimited by `---`:

```yaml
---
type: Concept
title: Document Title
description: One or two sentences describing the document's purpose.
tags: [tag1, tag2, tag3]
timestamp: 2026-07-13
provenance: docs/previous-location.md    # required for moved/renamed docs
story: e01s02                             # required for story-driven docs
---
```

### Field rules

| Field | Required | Rule |
|-------|----------|------|
| `type` | Yes | Must be one of: Concept, How-to, Tutorial, Reference, API Reference, Troubleshooting, Release Notes, Style Guide, Glossary. PascalCase. |
| `title` | Yes | Sentence case. Max 80 characters. |
| `description` | Yes | Complete sentence. Max 200 characters. |
| `tags` | Yes | Array of lowercase kebab-case tags. At least 3, at most 8. |
| `timestamp` | Yes | ISO 8601 date (YYYY-MM-DD). |
| `provenance` | Conditional | Required when the document was moved, renamed, or consolidated from another location. |
| `story` | Conditional | Required for documents created as part of an epic story. Value must match the story ID (e.g., `e01s04`). |

---

## Good Docs Template Sections

Each document type uses a specific body template. Do not deviate from the section headings.

### Concept

```
## Overview
## Glossary (optional, include if the concept introduces new terms)
## {topic heading 1}
## {topic heading 2}
```

### How-to

```
## Overview
## Before you start              (prerequisites)
## Step-by-step guide            (numbered steps)
## See also                      (related docs)
```

### Tutorial

```
## Overview
## Learning objectives
## Prerequisites
## {lesson 1}
## {lesson 2}
## Summary
## Next steps
```

### Reference

```
## Overview
## {structured entries}          (tables, lists, or structured data)
```

### API Reference

```
## Overview
## Authentication
## Endpoints                     (one subsection per endpoint)
## Errors
## Rate limiting
```

### Troubleshooting

```
## Overview
## {pattern 1}                   (for each failure pattern:)
### Symptom
### Cause
### Fix
```

### Release Notes

```
## Overview
## {change category section}     (grouped by theme: Features, Fixes, etc.)
## Upcoming
```

### Style Guide

```
## Overview
## {convention category 1}
## {convention category 2}
```

### Glossary

```
## Overview
| Term | Definition |                (alphabetical table)
```

---

## Akita Naming

File and directory names must follow the **Akita naming convention**: each name must be unique enough that a `grep -r '<name>' /Users/danielvm/Developer/` returns fewer than 5 results across the entire portfolio.

### Rules

- Use kebab-case for all file names.
- Prefer compound names that include the document's domain or context (e.g., `guard-git-safety-hooks.md` not `hooks.md`).
- Before naming a new file, test it:

  ```bash
  grep -r '<candidate-name>' /Users/danielvm/Developer/ | wc -l
  ```

  If the count is 5 or higher, choose a more specific name.

### Examples

| Poor name | Good name | Why |
|-----------|-----------|-----|
| `hooks.md` | `guard-git-safety-hooks.md` | "hooks" appears in dozens of repos |
| `quickstart.md` | `github-quickstart.md` | "quickstart" appears in many projects |
| `learnings.md` | `bigpowers-methodology-overview.md` | "learnings" is too generic |

---

## Ousterhout Size Caps

Every document file must respect Ousterhout's "deep module" principle applied to documentation: **one file, one coherent topic, at most 120 lines**.

### Rules

- **Hard cap:** 120 lines per file. Break longer documents into multiple files.
- **Soft warning:** At 80 lines, consider splitting.
- **Exception:** Glossary and reference tables may exceed 120 lines if the data is uniform and belongs together.
- **Enforcement:** `scripts/validate-docs.sh` (e01s05) checks this rule.

---

## Provenance Links

When a document is moved, renamed, or consolidated, the new file must include a `provenance:` field in its frontmatter pointing to the old location.

### Rules

- `provenance: docs/old-location.md` for simple moves.
- `provenance: docs/old-location/ (consolidated)` for consolidated directories.
- The old file must be deleted (no redirects — the provenance field serves as the trace).

### Examples

```yaml
provenance: docs/explanation/bigpowers-learnings.md
```

```yaml
provenance: docs/reference/audit-history/ (consolidated)
```

---

## Story Tags

Documents created as part of an epic story must include a `story:` field in frontmatter.

### Rules

- `story:` value must match the story ID from `specs/release-plan.yaml` or the epic capsule.
- Story tags enable traceability: running `grep -r 'story: e01s04' docs/` lists all files created in that story.
- Do not update `story:` when a document is edited in a later story — it records origin only.

### Examples

```yaml
story: e01s04
```
