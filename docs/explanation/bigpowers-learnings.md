---
type: Explanation
title: bigpowers — what it is and what the .github reference repo should not duplicate
context: methodology
---

# bigpowers — what it is and what the .github reference repo should not duplicate

`bigpowers` (`/Users/danielvm/Developer/bigpowers`) is the methodology engine behind essentially every repo in this portfolio — not a project among the 28, but the tool that shaped how each one was built. This doc records what it actually does, so the `.github` reference repo builds on it instead of re-explaining or re-inventing pieces of it.

## What it is

A prescriptive, spec-driven methodology for building software with AI coding agents (Claude Code, Gemini CLI, Cursor, pi), published as an npm package with 77 "skills" — each a targeted instruction set for one phase of development. Installed via `bigpowers setup`, which links skills into whichever agent tooling is present.

## The 6-phase lifecycle

Every project seeded with bigpowers follows `orchestrate-project`:

1. **Discover** — `survey-context`, `research-first`, `elaborate-spec`
2. **Elaborate** — `model-domain`, `grill-me`, `define-language`, `deepen-architecture`
3. **Plan** — `scope-work`, `slice-tasks`, `plan-work` → `release-plan.yaml` with a BCP (business complexity points) baseline
4. **Build** — per-story 8-step cycle: `survey-context` → `plan-work` → `kickoff-branch` → `develop-tdd` (RED/GREEN/REFACTOR) → `verify-work` → `audit-code` (≥94% quality gate) → `commit-message` → `release-branch`
5. **Verify** — `run-evals`, project-level `verify-work`
6. **Release** — `semantic-release` to the first `1.0.0` tag

State persists in `specs/state.yaml` across sessions so an agent can resume mid-story via `handoff.next_skill`.

## The parts worth reusing directly, not reinventing

**`specs/conventions-wiki/` — CONVENTIONS.md, decomposed.** `scripts/decompose-conventions.sh` splits the single `CONVENTIONS.md` into one atomic file per `##` heading (`p0-critical-never-violate.md`, `code-style.md`, etc.), each with:
```yaml
---
type: Convention
title: P0 — Critical (never violate)
context: conventions
---
```
This is exactly the "flat directory + `type:` frontmatter instead of deep folders" pattern proposed for the `.github` reference repo's own `docs/` — except bigpowers proves it should be *generated* from one source file by a script, not hand-maintained as N separate files that can drift from each other. Worth adopting the same generation approach for the reference repo's own convention docs once there are more than a handful.

**`specs/metrics/*.okf.md` — a DORA pipeline already running.** Each story's metrics file uses the `.okf.md` extension and `okf_kind`/`okf_version` frontmatter fields, tracking the four DORA keys (lead time, deployment frequency, change failure rate, time to restore) plus agent-specific telemetry (token cost, cache hit rate, tool calls). Since DX Core 4 is DORA + SPACE + DevEx unified, `reference/metrics/dx-core-4-metrics.md` in the `.github` repo should be framed as **extending this existing pipeline to portfolio scale** — rolling up per-repo DORA numbers bigpowers is already recording, rather than standing up a parallel metrics system.

**The risk-tier hard gates.** `always-green`, `no-direct-coding`, `traceability`, `no-generated-edits` are P0 (never violate). These are the actual enforcement layer for "principles" — the `.github` repo doesn't need its own principles doc; it needs a pointer to these plus whatever cross-repo rules bigpowers doesn't cover (CI/CD, deploy, Pages).

## A real bug found while researching this

`seed-conventions`'s documented design: `CLAUDE.md` and `GEMINI.md` should be **symlinks** to one canonical `AGENTS.md` (with a copy fallback only "on Windows when symlink fails"). Checked file timestamps across several repos on this machine — they are not symlinks:

```
big-quiqui/AGENTS.md   Jul 2
big-quiqui/CLAUDE.md   Jul 1
big-quiqui/GEMINI.md   Jun 30
```

Three different modification dates on files that are supposed to be one canonical file plus two symlinks to it. Something in the toolchain (likely a copy/backup/transfer step, or an older bigpowers version predating the symlink change) is dereferencing the symlinks into independent real files, which then drift silently since nothing keeps them in sync. This affects at least `big-stream`, `big-clipboard-manager`, `big-olive-books`, `big-quiqui`, `big-kickass-readme`, `big-dock-locker`, and `big-dock-locker-site` — all showing near-identical-but-not-identical file sizes across the three files.

**Fix, tracked in `docs/how-to/agent-context/fix-agents-md-symlink-drift.md`:** re-run `seed-conventions` (or a dedicated repair script) across affected repos to re-establish the symlinks, and investigate what step in the workflow breaks them, so it doesn't silently recur on the next repo.

## What this means for the .github repo's scope

Don't build: a competing principles/conventions doc, a competing metrics pipeline, a competing "how to structure a new project" guide — bigpowers already owns all three, well, and better than a doc written from outside it would.

Do build: the layer bigpowers doesn't touch because it works within one repo at a time — CI/CD templates, the `bigbase-deploy` action, GitHub Pages/Wiki guidance, and a portfolio-wide rollup (audit history, DX Core 4 aggregated across repos) of the per-repo signals bigpowers is already generating.
