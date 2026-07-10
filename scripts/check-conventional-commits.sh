#!/usr/bin/env bash
# Check that all commits in a branch range follow Conventional Commits.
# Usage: bash scripts/check-conventional-commits.sh [base-branch]
# Default base: origin/main
set -euo pipefail

BASE="${1:-origin/main}"

echo "Checking commits: $BASE..HEAD"
FAILS=0

while IFS= read -r line; do
  if ! echo "$line" | grep -qE "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?!?: "; then
    echo "FAIL: $line"
    ((FAILS++))
  fi
done < <(git log "$BASE..HEAD" --oneline)

if [ "$FAILS" -gt 0 ]; then
  echo "$FAILS non-conventional commit(s) found"
  exit 1
fi

echo "PASS: All commits follow Conventional Commits"
