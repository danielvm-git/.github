---
bug_id: BUG-2026-07-25-health-check-not-resilient-to-transient-curl-errors
status: fixed
severity: low
scope: actions/bigbase-deploy
title: Health check retry loop dies on the first transient curl connection error instead of retrying
---

## Problem

`actions/bigbase-deploy/action.yml`'s health-check step runs under
`shell: bash --noprofile --norc -e -o pipefail` and does:

```bash
for i in $(seq 1 "$ATTEMPTS"); do
  STATUS=$(curl -s -o /dev/null -w '%{http_code}' "${{ inputs.site_url }}")
  if [ "$STATUS" = "200" ] || [ "$STATUS" = "301" ] || [ "$STATUS" = "302" ]; then
    echo "✅ Site LIVE (HTTP $STATUS)"
    exit 0
  fi
  echo "Attempt $i/$ATTEMPTS: HTTP $STATUS, waiting ${INTERVAL}s..."
  sleep "$INTERVAL"
done
```

If `curl` itself fails at the connection level (SSL handshake not ready yet on a
freshly-created subdomain, DNS not yet propagated, connection refused during the
first second the process is starting) it exits non-zero (e.g. exit 35 for SSL
connect error). Because the step's shell has `set -e`, the *entire step* aborts
on that first `curl` failure — the loop never reaches attempt 2, `sleep`, or any
of the remaining `ATTEMPTS - 1` retries. The 8-attempt/10s-interval retry budget
this step is designed to have is only actually exercised for HTTP-level failures
(wrong status code), never for connection-level ones — which are exactly the
failures most likely in the first few seconds after a fresh deploy.

**Observed twice this session** (`bigbase-canary-go`'s very first deploy,
`bigbase-canary-node`'s deploy): the GitHub Actions run reports `failure` /
`Process completed with exit code 35`, while the actual deployment succeeded
seconds later — confirmed by querying `GET /api/sites/{id}` (`status: "running"`)
and curling the site directly (correct content, correct commit SHA in
`window.__BIGBASE_METADATA__`). A false negative: the workflow fails, the
deploy didn't.

## Fix Approach

Don't let a connection-level `curl` failure escape the loop. Either:
- Wrap the `curl` call so its own exit status doesn't propagate (e.g.
  `STATUS=$(curl ... || echo "000")`), letting the existing "not 200/301/302 →
  sleep and retry" branch handle it uniformly, or
- Run this specific step's body under `set +e` for the curl line only.

## Acceptance Criteria

- [ ] A connection-level curl failure on attempt 1 does not abort the step —
      it's treated the same as any other non-2xx/3xx result and retried
- [ ] Regression: a genuinely down site still fails after `ATTEMPTS` retries
- [ ] Existing successful-health-check path unchanged

## Resolution

**Fixed:** 2026-07-25
**Fix applied:** `STATUS=$(curl ... || echo "000")` in the composite action's own health-check
step (`actions/bigbase-deploy/action.yml`) and in all six `deploy-*.yml` templates
(go/node/python/static/monorepo/php). A connection-level curl failure now yields `STATUS=000`,
which the existing "not 200/301/302 → sleep and retry" branch already handles — no more `set -e`
abort on attempt 1.
**Evidence:** `yamllint workflow-templates/ workflows/ actions/` clean; all six templates
YAML-parse; retry-loop logic unchanged for the success and genuinely-down-site paths.
**Follow-up required:** the `bigbase-deploy` `v1` tag must be retagged to include this commit —
consumers pin `@v1` directly (confirmed: all four `bigbase-canary-*` repos do), and `v1` is
already a floating tag repointed at each release (currently at the v3.1.0 merge commit), so
retagging is the established mechanism here, not a one-off exception.
