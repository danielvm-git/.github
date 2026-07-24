# CI/CD Template Refactor

> **Status (2026-07-24):** Implemented via checklist-aligned 3.0.0 template split (`test-build-release-*` + `deploy-*` pairs). The **solo-dev CI/CD audit checklist** is the Definition of Done and outranks this document. The "Explicitly rejected" section below is **void** — checklist §1 requires separate deploy workflows.

Reconciled gap list from two independent audits of `workflow-templates/ci-cd-*.yml` and
`actions/bigbase-deploy` against the bigpowers solo-dev CI/CD checklist. Bypasses full
epic/story tooling (`specs/release-plan.yaml` + `specs/epics/` don't exist in this repo yet) —
plain prioritized task list instead.

**Scope: this repo's templates only** (`workflow-templates/`, `actions/bigbase-deploy/`,
`workflows/security-baseline.yml`, `docs/reference/contracts/`, `docs/how-to/migrate-ci-cd/`).
Do not touch the 28 downstream consumer repos — they pick up fixes on their next template sync.

---

## High priority

### 1. Deploy job is not shielded from cancellation
All `ci-cd-*.yml` share one workflow-level `concurrency` group
(`cancel-in-progress: true`, e.g. `ci-cd-node.yml:13-16`) that also covers the `deploy` job — a
second push to `main` while a deploy is in flight kills it mid-execution.

**Fix:** add a job-level `concurrency:` override on the `deploy` job in every `ci-cd-*.yml`:
```yaml
deploy:
  concurrency:
    group: deploy-${{ github.ref }}
    cancel-in-progress: false
```
Do **not** split into a separate `deploy.yml` — the single-file-per-stack consolidation was a
deliberate, documented decision (`docs/how-to/migrate-ci-cd/migration-plan.md`, PR #11,
2026-07-11). Job-level `concurrency:` fixes the actual bug without reversing that decision.
`workflows/security-baseline.yml:17-21` already documents this rule; it was never applied to
the `deploy` job specifically.

### 2. No real artifact handoff between CI build and deploy
`actions/bigbase-deploy/action.yml:55-66` POSTs `{branch, app_type}` to BigBase's API, which
rebuilds server-side from branch HEAD — it never consumes what CI built.
`ci-cd-static.yml:49-55,132-135` uploads/downloads a `dist/` artifact that is never referenced
by the deploy step (dead code).

**Fix:** pick one coherent model and implement it everywhere:
- (a) make `bigbase-deploy` accept and push the actual built artifact, or
- (b) drop the artifact upload/download steps entirely and instead pass the semantic-release
  commit SHA/tag through to the deploy call, so what's deployed is at least pinned to what CI
  tested rather than "whatever `main` is right now."

### 3. `bigbase-deploy` pinned to `@main`, not a tag or SHA
All 5 `ci-cd-*.yml` templates reference `danielvm-git/.github/actions/bigbase-deploy@main` — a
moving branch ref. Same anti-pattern already flagged elsewhere in the portfolio
(`docs/reference/audit-history/2026-07-audit.md`, `dtolnay/rust-toolchain@master`).

**Fix:** tag releases of this repo (or at least the `bigbase-deploy` path) and pin all 5
templates to a version tag.

### 4. `ci-cd-go.yml` / `ci-go.yml`: lint doesn't gate deploy
The `lint` job (golangci-lint, `ci-cd-go.yml:46-58`) is never referenced by any downstream
`needs:` — `semantic-release` (`needs: [ci, verify]`) and `deploy`
(`needs: [ci, verify, semantic-release]`) both omit it. A failing lint blocks the PR check but
not an auto-deploy on direct push to `main`.

**Fix:** add `lint` to both `needs:` arrays in `ci-cd-go.yml` and `ci-go.yml`.

### 5. `main` on this repo has no branch protection
Verified live: `gh api repos/danielvm-git/.github/branches/main/protection` → `404 Branch not
protected`. Contradicts `CLAUDE.md` § Conventions ("No direct work on `main`... Branch
protection: require PR, require CI pass, no force-push").

**Fix:** configure branch protection on `main` requiring the `ci-cd` status checks and
disallowing force-push — or explicitly document a solo-owner exception if intentional.

---

## Medium priority

### 6. `environment: production` missing on BigBase-deploy jobs
Not set in `ci-cd-node.yml:117`, `-go:124`, `-python:124`, `-static:124`, `-monorepo:145`. Only
the GitHub Pages templates set an `environment:`.

**Fix:** add `environment: production` to all 5 BigBase `deploy` jobs (deployment history +
secret scoping, no approval rule needed).

### 7. No rollback path for BigBase deploys
`actions/bigbase-deploy` fails the job on a bad health check and leaves the site as-is. The
sibling `bigbase` app repo's own `release-deploy.yml` already has backup + auto-rollback on
failed health check (per `docs/reference/audit-history/2026-07-audit.md`).

**Fix:** port an equivalent backup/rollback pattern into `actions/bigbase-deploy`, or document a
manual revert procedure in `docs/reference/contracts/bigbase-deploy-contract.md`.

### 8. No verify-artifact step before deploy
Moot until #2 is resolved, but once there's a real artifact, add a step that confirms it exists
and is non-empty before invoking the deploy call.

---

## Low priority / hygiene

### 9. Docs deploys have no test gate
`deploy-pages-mkdocs.yml` / `deploy-pages-starlight.yml` trigger on their own `push` + `paths`
filter, independent of any `ci-cd-*.yml` passing. Low risk (docs builds), but worth a documented
exception or a minimal build-check step.

### 10. Dead code: "Export deploy token" step
`run: echo "DEPLOY_TOKEN=..." >> "$GITHUB_ENV"` in `ci-cd-node.yml:48-49`, `-go:43-44`,
`-python:57-58`, `-static:57-58`. Sets an env var nothing reads (deploy pulls the secret
directly; job-level env doesn't cross job boundaries anyway). Not an active leak, but delete it —
inconsistent (absent from `ci-cd-monorepo.yml`) and needlessly widens the token's exposure
surface.

### 11. golangci-lint installed via unpinned script
`curl .../golangci-lint/master/install.sh | sh` in `ci-cd-go.yml:55` / `ci-go.yml:50` — same
risk class as #3 (branch ref, not a version).

### 12. CHANGELOG claims conditional deploy that doesn't exist
`workflow-templates/CHANGELOG.md` says "Conditional BigBase deploy (skips if no secrets
configured)" — no such condition exists in any template; deploy just runs and
`bigbase-deploy`'s "Validate token present" step hard-fails if the token is empty. Either
implement skip-if-missing-secrets, or correct the changelog.

### 13. Superfluous long-lived branches in triggers
All `ci-cd-*.yml` trigger on `[main, develop, master]` for both `push` and `pull_request` —
inconsistent with a stated trunk-based, solo-dev pattern. Trim to `main` only (or make
configurable per repo).

### 14. [Info only, not a pipeline change] No rotation policy for `BIGBASE_DEPLOY_TOKEN`
OIDC doesn't apply here (BigBase is a custom API, not AWS/GCP/Azure — the checklist's OIDC
bullet is scoped to those). Track token rotation as a documentation/process item, not code.

---

## Explicitly rejected (void — superseded by 3.0.0)

> These rejections applied to the 2.0.0 consolidated model. Template **3.0.0** implements the split; the checklist is the Definition of Done.

- ~~**Splitting `ci-cd-*.yml` into `test-build-release.yml` + `deploy.yml` via `workflow_run`**~~ — **now implemented** in 3.0.0. Job-level concurrency was insufficient for deploy shielding; separate workflows with `cancel-in-progress: false` on deploy satisfy checklist item #1.
- **Requiring `needs:` between `ci` and `verify`** — they intentionally run in parallel; they check orthogonal things (code correctness vs. commit hygiene), and the real gate (`semantic-release`/`deploy`) already requires both via `needs: [ci, verify]`. Not a defect.
- **Splitting lint/test/build into separate jobs instead of sequential steps** — bundling into one `ci` job is an acceptable, simpler solo-dev pattern; a failed step still stops the job. Not worth splitting purely for checklist literalism.

## Definition of Done (checklist)

Template 3.0.0 is complete when every stack pair satisfies the bigpowers solo-dev CI/CD checklist:

1. Deploy shielded from cancellation (`deploy.yml` with `cancel-in-progress: false`)
2. Real artifact handoff (deploy-meta JSON with pinned SHA)
3. `bigbase-deploy` pinned to a version tag, not `@main`
4. Lint gates deploy where applicable (e.g. Go golangci-lint in `needs:`)
5. `environment: production` on BigBase deploy jobs
6. `scripts/validate-templates.sh` enforces concurrency policy per template type
7. `workflows/test-build-release.yml` dogfoods validation on push/PR to main
