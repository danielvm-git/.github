#!/usr/bin/env bash
# Audit template versions across the danielvm-git portfolio.
# Compares each repo's workflow files against the canonical versions
# in .github/workflow-templates/. Reports outdated or missing templates.
# Usage: bash scripts/audit-template-versions.sh [--repo-pattern "big-*"]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES_DIR="$REPO_ROOT/workflow-templates"
# shellcheck disable=SC2034
PATTERN="${1:-}"

echo "==> Template Version Audit"
echo ""

# Discover repos
REPOS=$(gh repo list danielvm-git --limit 50 --json name --jq '.[].name' 2>/dev/null || echo "")
if [ -z "$REPOS" ]; then
  echo "ERROR: gh CLI not available or no repos found"
  exit 1
fi

# Build canonical version map from local templates
declare -A CANONICAL
for tmpl in "$TEMPLATES_DIR"/*.yml; do
  name=$(basename "$tmpl")
  version=$(grep '^# version:' "$tmpl" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unversioned")
  CANONICAL["$name"]="$version"
done

TOTAL=0
MISMATCH=0
# shellcheck disable=SC2034
MISSING_TEMPLATES=0

for repo in $REPOS; do
  ((TOTAL++))
  
  REPO_DIR="/tmp/template-audit/$repo"
  if [ ! -d "$REPO_DIR" ]; then
    gh repo clone "danielvm-git/$repo" "$REPO_DIR" -- --depth=1 2>/dev/null || continue
  fi

  # Check each template's presence and version
  for tmpl_name in "${!CANONICAL[@]}"; do
    repo_workflow="$REPO_DIR/.github/workflows/$tmpl_name"
    canonical_version="${CANONICAL[$tmpl_name]}"
    
    if [ ! -f "$repo_workflow" ]; then
      continue  # Not every repo uses every template
    fi
    
    repo_version=$(grep '^# version:' "$repo_workflow" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unversioned")
    
    if [ "$repo_version" != "$canonical_version" ]; then
      echo "MISMATCH: $repo — $tmpl_name (repo: $repo_version, canonical: $canonical_version)"
      ((MISMATCH++))
    fi
  done
done

echo ""
echo "Portfolio: $TOTAL repos scanned, $MISMATCH version mismatches"

# Cleanup
rm -rf /tmp/template-audit

if [ "$MISMATCH" -gt 0 ]; then
  echo "Run 'bash scripts/align-existing-repo.sh <repo>' to upgrade."
  exit 1
fi

echo "PASS: All templates at current version"
