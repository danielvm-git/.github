#!/usr/bin/env bash
# Preflight — run before any forward work in this repo.
# Validates YAML workflows and actions, lints shell scripts.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

echo "==> Preflight: .github template repo"

# YAML lint
if command -v yamllint &>/dev/null; then
  echo "--- yamllint ---"
  if yamllint "$REPO_ROOT/workflow-templates/" "$REPO_ROOT/workflows/" "$REPO_ROOT/actions/" 2>&1; then
    ((PASS++)) || true
  else
    ((FAIL++)) || true
  fi
else
  echo "[SKIP] yamllint not installed (pip install yamllint)"
fi

# ShellCheck
if command -v shellcheck &>/dev/null && ls "$REPO_ROOT/scripts/"*.sh &>/dev/null 2>&1; then
  echo "--- shellcheck ---"
  if shellcheck "$REPO_ROOT/scripts/"*.sh 2>&1; then
    ((PASS++)) || true
  else
    ((FAIL++)) || true
  fi
else
  echo "[SKIP] No shell scripts to lint or shellcheck not installed"
fi

# Validate AGENTS.md has no placeholders
if grep -q '\[One sentence' "$REPO_ROOT/AGENTS.md" 2>/dev/null; then
  echo "FAIL: AGENTS.md still has placeholder text"
  ((FAIL++)) || true
else
  echo "PASS: AGENTS.md is filled in"
  ((PASS++)) || true
fi

echo ""
echo "Preflight: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
