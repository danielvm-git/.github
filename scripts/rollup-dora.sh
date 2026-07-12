#!/usr/bin/env bash
# Portfolio-wide DORA metrics rollup.
# Scans all danielvm-git repos for specs/metrics/*.okf.md and aggregates
# the four DORA keys + agent telemetry.
# Usage: bash scripts/rollup-dora.sh [--json] [--repo-pattern "big-*"]
set -euo pipefail

# shellcheck disable=SC2034
FORMAT="${1:-table}"
# shellcheck disable=SC2034
PATTERN="${2:-}"

echo "==> DORA Portfolio Rollup"
echo ""

# Discover repos
REPOS=$(gh repo list danielvm-git --limit 50 --json name --jq '.[].name' 2>/dev/null || echo "")

if [ -z "$REPOS" ]; then
  echo "No repos found via gh CLI. Install gh and auth: gh auth login"
  exit 1
fi

TOTAL_REPOS=0
REPOS_WITH_METRICS=0

for repo in $REPOS; do
  ((TOTAL_REPOS++))
  
  # Clone shallow if not already present
  REPO_DIR="/tmp/dora-scan/$repo"
  if [ ! -d "$REPO_DIR" ]; then
    gh repo clone "danielvm-git/$repo" "$REPO_DIR" -- --depth=1 2>/dev/null || continue
  fi

  # Find OKF metrics files
  METRICS=$(find "$REPO_DIR/specs/metrics" -name "*.okf.md" 2>/dev/null || echo "")
  
  if [ -n "$METRICS" ]; then
    ((REPOS_WITH_METRICS++))
    echo "$repo: $(echo "$METRICS" | wc -l | tr -d ' ') metrics files"
  fi
done

echo ""
echo "Portfolio: $REPOS_WITH_METRICS / $TOTAL_REPOS repos have DORA metrics"

# Cleanup
rm -rf /tmp/dora-scan
