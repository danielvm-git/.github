# big-release Option B Gap Register

**Status:** Tracking artifact — gaps to full centralized CI/CD reuse (Option B)
**Date:** 2026-08-03
**Context:** [Discussion #32](https://github.com/danielvm-git/.github/discussions/32) (Centralized CI/CD) and the 5-repo semantic-release → big-release migration ([plan](https://github.com/danielvm-git/big-release/discussions/72))

## Summary

Five Python repos were migrated from `semantic-release` (JS and Python flavors) to
`big-release` using **Option A: in-place swap** — each repo keeps its bespoke workflow
and only the release step changes to the big-release install/run block from the central
`workflow-templates/test-build-release-python.yml` (v4.1.0).

Option B (full central reuse: `uses: danielvm-git/.github/.github/workflows/...@main`
with `release_tool: "big-release"`) is the eventual DRY end-state. The gaps below are
what each repo must resolve before it can adopt the reusable workflow.

## Per-repo gaps

### big-bolao
- **Node web build**: the `web-build-commit` job is bespoke (Node + web build) and
  depends on the release job's `new_release` output. The central Python template has no
  Node web-build concept.
- **VERSION sync**: runtime reads `bolao/util.py` → root `VERSION`; the central template's
  sync step must gain a `version_file` input or the repo keeps the bespoke step.
- **Deploy boundary**: BigBase deploy uses a `deploy-meta` artifact; needs a clean
  contract with the central template's output artifact.
- **Action**: fold Node web-build + deploy boundary into a central fullstack template, or
  declare big-bolao permanently bespoke. Wire `release_tool: "big-release"` input.

### big-personal-finance
- Already matches the central Python template shape closely.
- **Action**: adopt the central python template directly (`release_tool: "big-release"`)
  and drop the bespoke `release.yml`; move the VERSION + CHANGELOG sync into the shared step.

### grimoire
- Uses the central template shape (adapted v3.0.0) with a bespoke `test-build-release.yml`.
- **Action**: adopt the central python template with `release_tool: "big-release"`; move
  the preflight and Conventional-Commits/AI-attribution checks to template inputs.
- Note: the CC/AI-attribution checks now harden against rewritten history
  (`merge-base --is-ancestor` fallback) — fold this hardening back into the central template.

### big-counter
- Bespoke `release.yaml` (separate from the central template layout) with a `__version__`
  in `src/bcp/__init__.py` and a `setup.py` version.
- **Action**: migrate `release.yaml` to the central template; move
  `__version__`/`setup.py` sync into the shared big-release sync step.
- Note: CI currently fails a `ruff format --check` on `docs/usage/*.md` — pre-existing
  drift from the unpinned `ruff>=0.8.0` floating dependency, unrelated to this migration.
  Pin ruff or reformat docs separately.

### big-vps-oracle
- GHCR image build + Oracle VPS deploy (`deploy.yml` reads `release-version.txt` artifact)
  does not match the BigBase deploy action.
- **Action**: document this as the one repo that legitimately stays bespoke until the
  central template gains a container-deploy option. The `release-version.txt` artifact
  contract must keep working.

## Central template gaps (repo-agnostic)

- Add `release_tool` input wiring end-to-end (template already declares it for
  `test-build-release-python.yml`).
- Fold the CC/AI-attribution `merge-base --is-ancestor` hardening into the shared checks.
- Consider a container-deploy (GHCR) publish option to absorb big-vps-oracle.

## Governance

This register lives in the `.github` template repo so maintainers of any portfolio repo
can reference the path to full central reuse. Update it when a repo closes a gap or when
the central template adds a capability listed here.
