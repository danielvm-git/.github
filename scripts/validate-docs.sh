#!/usr/bin/env bash
# validate-docs.sh
#
# Validates docs/ against bigpowers soft rules.
# Exits non-zero on failure — can be added to pre-commit or CI.
#
# Rules:
#   1. Every .md (except index.md, log.md) has YAML frontmatter with type: field
#   2. type: values match Good Docs template names (case-insensitive)
#   3. No file exceeds 120 lines (Ousterhout cap)
#   4. Every folder has index.md
#   5. story-driven docs have provenance: field

set -euo pipefail

DOCS_DIR="$(cd "$(dirname "$0")/../docs" && pwd)"
EXIT_CODE=0

# Allowed type values (case-insensitive match)
ALLOWED_TYPES="Concept How-to Tutorial Reference ApiReference Troubleshooting ReleaseNotes StyleGuide Glossary Index Explanation"

# Normalize for case-insensitive comparison
normalize_type() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Build allowed set (lowercase)
ALLOWED_SET=""
for t in $ALLOWED_TYPES; do
  ALLOWED_SET="$ALLOWED_SET $(normalize_type "$t")"
done

check_has_type() {
  local file="$1"
  local type_val
  type_val=$(awk '/^---$/ { count++; next } count == 1 && /^type:/ { sub(/^[^:]+:[[:space:]]*/,""); gsub(/^["'\'']|["'\'']$/,""); print; exit } count >= 2 { exit }' "$file")

  if [ -z "$type_val" ]; then
    echo "  FAIL: $file — missing type: field in frontmatter"
    return 1
  fi

  # Check type is in allowed list (case-insensitive)
  local normalized
  normalized=$(normalize_type "$type_val")
  local found=0
  for t in $ALLOWED_SET; do
    if [ "$normalized" = "$t" ]; then
      found=1
      break
    fi
  done

  if [ "$found" -eq 0 ]; then
    echo "  FAIL: $file — invalid type: '$type_val' (not in Good Docs template names)"
    return 1
  fi

  return 0
}

check_line_count() {
  local file="$1"
  local max_lines=120
  local lines
  lines=$(wc -l < "$file")
  if [ "$lines" -gt "$max_lines" ]; then
    echo "  FAIL: $file — $lines lines (exceeds $max_lines Ousterhout cap)"
    return 1
  fi
  return 0
}

check_has_provenance() {
  local file="$1"
  local base
  base=$(basename "$file")

  # Only check files that look story-driven (in a story/epic context)
  # We check if file has story: field in frontmatter but missing provenance:
  local has_story
  has_story=$(awk '/^---$/ { count++; next } count == 1 && /^story:/ { print "yes"; exit } count >= 2 { exit }' "$file")
  local has_provenance
  has_provenance=$(awk '/^---$/ { count++; next } count == 1 && /^provenance:/ { print "yes"; exit } count >= 2 { exit }' "$file")

  if [ "$has_story" = "yes" ] && [ "$has_provenance" != "yes" ]; then
    echo "  FAIL: $file — has story: field but missing provenance: field"
    return 1
  fi
  return 0
}

echo "Validating docs/ ..."
echo ""

# --- Rule 1 & 2: Frontmatter + type validation ---
echo "[Rule 1/2] Checking YAML frontmatter with valid type: field..."
rule1_fail=0
while IFS= read -r -d '' md_file; do
  base=$(basename "$md_file")

  # Exclude index.md and log.md
  case "$base" in
    index.md) continue ;;
    log.md)   continue ;;
  esac

  if ! check_has_type "$md_file"; then
    rule1_fail=1
  fi
done < <(find "$DOCS_DIR" -name '*.md' -type f -print0)

if [ "$rule1_fail" -eq 0 ]; then
  echo "  PASS: All checked files have valid type: field"
else
  EXIT_CODE=1
fi
echo ""

# --- Rule 3: Line count cap ---
echo "[Rule 3] Checking Ousterhout 120-line cap..."
rule3_fail=0
while IFS= read -r -d '' md_file; do
  if ! check_line_count "$md_file"; then
    rule3_fail=1
  fi
done < <(find "$DOCS_DIR" -name '*.md' -type f -print0)

if [ "$rule3_fail" -eq 0 ]; then
  echo "  PASS: All files within 120-line limit"
else
  EXIT_CODE=1
fi
echo ""

# --- Rule 4: Folder index.md check ---
echo "[Rule 4] Checking every docs/ subfolder has index.md..."
rule4_fail=0
while IFS= read -r -d '' subdir; do
  if [ ! -f "$subdir/index.md" ]; then
    echo "  FAIL: $subdir — missing index.md"
    rule4_fail=1
  fi
done < <(find "$DOCS_DIR" -mindepth 1 -maxdepth 1 -type d -print0)

# Also check nested folders that contain .md files
while IFS= read -r -d '' subdir; do
  # Skip immediate docs/ subdirs (already checked above)
  parent=$(dirname "$subdir")
  if [ "$parent" = "$DOCS_DIR" ]; then
    continue
  fi
  # Check if this directory contains .md files
  if find "$subdir" -maxdepth 1 -name '*.md' -type f | grep -q .; then
    if [ ! -f "$subdir/index.md" ]; then
      echo "  FAIL: $subdir — missing index.md (contains .md files)"
      rule4_fail=1
    fi
  fi
done < <(find "$DOCS_DIR" -mindepth 2 -type d -print0)

if [ "$rule4_fail" -eq 0 ]; then
  echo "  PASS: All folders with .md files have index.md"
else
  EXIT_CODE=1
fi
echo ""

# --- Rule 5: Provenance for story-driven docs ---
echo "[Rule 5] Checking story-driven docs have provenance: field..."
rule5_fail=0
while IFS= read -r -d '' md_file; do
  if ! check_has_provenance "$md_file"; then
    rule5_fail=1
  fi
done < <(find "$DOCS_DIR" -name '*.md' -type f -print0)

if [ "$rule5_fail" -eq 0 ]; then
  echo "  PASS: story-driven docs have provenance fields (or no story-driven docs found)"
else
  EXIT_CODE=1
fi
echo ""

# --- Summary ---
if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Validation PASSED — all checks green."
else
  echo "Validation FAILED — review issues above."
fi

exit $EXIT_CODE
