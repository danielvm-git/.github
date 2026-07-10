#!/usr/bin/env bash
# Validate all workflow templates — yamllint + required fields check.
# Usage: bash scripts/validate-templates.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES_DIR="$REPO_ROOT/workflow-templates"
PASS=0
FAIL=0

echo "==> Template Validation"
echo ""

# YAML syntax check
if command -v yamllint &>/dev/null; then
  echo "--- yamllint ---"
  for f in "$TEMPLATES_DIR"/*.yml; do
    name=$(basename "$f")
    if yamllint "$f" >/dev/null 2>&1; then
      echo "  PASS: $name"
      ((PASS++))
    else
      echo "  FAIL: $name"
      yamllint "$f" 2>&1
      ((FAIL++))
    fi
  done
else
  echo "[SKIP] yamllint not installed (pip install yamllint)"
fi

# Required fields check
echo ""
echo "--- required fields ---"
REQUIRED=("name:" "on:" "permissions:" "concurrency:" "timeout-minutes:" "ubuntu-22.04" "# version:")
# Templates that legitimately don't use ubuntu-22.04 (e.g. Swift needs macOS)
UBUNTU_EXEMPT=("ci-swift.yml")

for f in "$TEMPLATES_DIR"/*.yml; do
  name=$(basename "$f")
  missing=""
  for field in "${REQUIRED[@]}"; do
    # Skip ubuntu-22.04 check for exempt templates
    if [ "$field" = "ubuntu-22.04" ]; then
      exempt=false
      for exempt_name in "${UBUNTU_EXEMPT[@]}"; do
        [ "$name" = "$exempt_name" ] && exempt=true
      done
      $exempt && continue
    fi
    if ! grep -q "$field" "$f"; then
      missing="$missing $field"
    fi
  done
  if [ -n "$missing" ]; then
    echo "  FAIL: $name — missing: $missing"
    ((FAIL++))
  else
    echo "  PASS: $name"
    ((PASS++))
  fi
done

# .properties.json check
echo ""
echo "--- .properties.json ---"
for f in "$TEMPLATES_DIR"/*.yml; do
  name=$(basename "$f" .yml)
  prop="$TEMPLATES_DIR/$name.properties.json"
  if [ -f "$prop" ]; then
    echo "  PASS: $name.properties.json"
    ((PASS++))
  else
    echo "  FAIL: $name — missing .properties.json"
    ((FAIL++))
  fi
done

echo ""
echo "Validation: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
