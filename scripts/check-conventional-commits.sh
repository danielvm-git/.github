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

# Check for prohibited Co-authored-by: footers in full commit bodies
if git log "$BASE..HEAD" --format="%B" | grep -qiE '^co[- ]authored[- ]by:'; then
  echo "FAIL: Co-authored-by: footer found — blocked by CONVENTIONS.md § Git Attribution"
  ((FAILS++))
fi

if [ "$FAILS" -gt 0 ]; then
  echo "$FAILS violation(s) found"
  exit 1
fi

echo "PASS: All commits follow Conventional Commits"
