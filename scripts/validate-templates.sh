#!/usr/bin/env bash
# Validate all workflow templates — yamllint + required fields check.
# Usage: bash scripts/validate-templates.sh
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES_DIR="$REPO_ROOT/workflow-templates"
PASS=0
FAIL=0

is_deploy_template() {
  local name="$1"
  [[ "$name" == deploy-*.yml ]]
}

is_test_build_release_template() {
  local name="$1"
  [[ "$name" == test-build-release-*.yml ]]
}

is_swift_template() {
  local name="$1"
  [[ "$name" == *swift*.yml ]]
}

echo "==> Template Validation"
echo ""

# YAML syntax check
if command -v yamllint &>/dev/null; then
  echo "--- yamllint ---"
  for f in "$TEMPLATES_DIR"/*.yml; do
    name=$(basename "$f")
    if yamllint "$f" >/dev/null 2>&1; then
      echo "  PASS: $name"
      ((PASS++)) || true || true
    else
      echo "  FAIL: $name"
      yamllint "$f" 2>&1
      ((FAIL++)) || true || true
    fi
  done
else
  echo "[SKIP] yamllint not installed (pip install yamllint)"
fi

# Required fields check
echo ""
echo "--- required fields ---"
REQUIRED=("name:" "on:" "permissions:" "concurrency:" "timeout-minutes:" "# version:")

for f in "$TEMPLATES_DIR"/*.yml; do
  name=$(basename "$f")
  missing=""
  for field in "${REQUIRED[@]}"; do
    if ! grep -q "$field" "$f"; then
      missing="$missing $field"
    fi
  done

  # Pinned ubuntu runner — exempt Swift (macOS) and deploy templates (workflow_run handoff)
  if ! is_deploy_template "$name" && ! is_swift_template "$name"; then
    if ! grep -q "ubuntu-22.04" "$f"; then
      missing="$missing ubuntu-22.04"
    fi
  fi

  if [ -n "$missing" ]; then
    echo "  FAIL: $name — missing:$missing"
    ((FAIL++)) || true
  else
    echo "  PASS: $name"
    ((PASS++)) || true
  fi
done

# Concurrency policy — 3.0.0 split: test-build-release cancels; deploy queues
echo ""
echo "--- concurrency policy ---"
for f in "$TEMPLATES_DIR"/*.yml; do
  name=$(basename "$f")
  if is_deploy_template "$name"; then
    if grep -q "cancel-in-progress: false" "$f"; then
      echo "  PASS: $name (deploy — cancel-in-progress: false)"
      ((PASS++)) || true || true
    else
      echo "  FAIL: $name — deploy template must set cancel-in-progress: false"
      ((FAIL++)) || true || true
    fi
  elif is_test_build_release_template "$name"; then
    if grep -q "cancel-in-progress: true" "$f"; then
      echo "  PASS: $name (test-build-release — cancel-in-progress: true)"
      ((PASS++)) || true || true
    else
      echo "  FAIL: $name — test-build-release template must set cancel-in-progress: true"
      ((FAIL++)) || true || true
    fi
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
    ((PASS++)) || true
  else
    echo "  FAIL: $name — missing .properties.json"
    ((FAIL++)) || true
  fi
done

echo ""
echo "Validation: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
