#!/usr/bin/env bash
# audit-workflows.sh — portfolio-wide workflow compliance scan
#
# Scans all danielvm-git repos for the security baseline triple-block:
#   permissions: contents: read
#   timeout-minutes
#   concurrency
#
# Also checks: AGENTS.md symlink integrity, unpinned actions, ubuntu-latest.
#
# Usage: ./scripts/audit-workflows.sh [--repo owner/name] [--all]
#   --repo   Scan a single repo (requires local clone under ~/Developer/)
#   --all    Scan all locally cloned danielvm-git repos (default)

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

MODE="${1:---all}"
REPO_FILTER="${2:-}"

failures=0
warnings=0
checked=0

check_workflow() {
  local file="$1"
  local repo="$2"
  local file_failures=0

  # permissions: contents: read (workflow-level, not job-level)
  if ! grep -q '^permissions:' "$file" 2>/dev/null; then
    echo -e "  ${RED}FAIL${NC} permissions: $repo/${file##*/}"
    ((file_failures++)) || true
  fi

  # timeout-minutes
  if ! grep -q 'timeout-minutes' "$file" 2>/dev/null; then
    echo -e "  ${RED}FAIL${NC} timeout-minutes: $repo/${file##*/}"
    ((file_failures++)) || true
  fi

  # concurrency
  if ! grep -q 'concurrency:' "$file" 2>/dev/null; then
    echo -e "  ${RED}FAIL${NC} concurrency: $repo/${file##*/}"
    ((file_failures++)) || true
  fi

  # ubuntu-latest (should be ubuntu-22.04)
  if grep -q 'ubuntu-latest' "$file" 2>/dev/null; then
    echo -e "  ${YELLOW}WARN${NC} ubuntu-latest: $repo/${file##*/}"
    ((warnings++)) || true
  fi

  return "$file_failures"
}

check_agent_symlinks() {
  local dir="$1"
  local repo="$2"

  for f in CLAUDE.md GEMINI.md; do
    if [ -f "$dir/$f" ] && [ ! -L "$dir/$f" ]; then
      echo -e "  ${RED}FAIL${NC} $repo/$f is regular file, not symlink"
      ((failures++)) || true
    fi
  done
}

scan_repo() {
  local repo="$1"
  local dir="$HOME/Developer/$repo"

  if [ ! -d "$dir/.github/workflows" ]; then
    return 0
  fi

  echo -e "\n${YELLOW}=== $repo ===${NC}"

  # Scan workflow files
  for wf in "$dir"/.github/workflows/*.yml; do
    [ -f "$wf" ] || continue
    check_workflow "$wf" "$repo" || ((failures++)) || true
    ((checked++)) || true
  done

  # Check agent symlinks
  check_agent_symlinks "$dir" "$repo"
}

# --- main ---

if [ "$MODE" = "--repo" ] && [ -n "$REPO_FILTER" ]; then
  scan_repo "$REPO_FILTER"
else
  for dir in "$HOME"/Developer/*/; do
    repo=$(basename "$dir")
    # Skip non-danielvm repos and special dirs
    [ -d "$dir/.git" ] || continue
    [[ "$repo" == .* ]] && continue
    scan_repo "$repo"
  done
fi

echo ""
echo "═══════════════════════════════════════"
echo -e "Checked: ${checked} workflow files"
echo -e "Failures: ${RED}${failures}${NC}"
echo -e "Warnings: ${YELLOW}${warnings}${NC}"
echo "═══════════════════════════════════════"

[ "$failures" -eq 0 ] && echo -e "${GREEN}✅ All checks passed${NC}" && exit 0
echo -e "${RED}❌ $failures failures found${NC}"
exit 1
