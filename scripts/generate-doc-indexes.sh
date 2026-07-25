#!/usr/bin/env bash
# generate-doc-indexes.sh
#
# Scans each docs/ subfolder for .md files, reads YAML frontmatter,
# and generates/overwrites index.md in each folder.
#
# Follows OKF §6 format:
#   # Section heading
#   * [Title](file.md) — description
#
# Idempotent — safe to run multiple times.
#
# Wiring options:
#   - Add to scripts/sync-skills.sh (if it exists) under a "refresh indexes" step
#   - Add as a pre-commit hook step
#   - Add as a CI step in ci-cd-monorepo.yml after the checkout step
#     Example:
#       - name: Refresh doc indexes
#         run: bash scripts/generate-doc-indexes.sh
#         working-directory: ${{ github.workspace }}

set -euo pipefail

DOCS_DIR="$(cd "$(dirname "$0")/../docs" && pwd)"

# Map folder names to display headings (PascalCase / proper case)
heading_of() {
  local dir="$1"
  case "$dir" in
    concept)         echo "Concept" ;;
    how-to)          echo "How-to" ;;
    tutorial)        echo "Tutorial" ;;
    reference)       echo "Reference" ;;
    api-reference)   echo "API Reference" ;;
    troubleshooting) echo "Troubleshooting" ;;
    release-notes)   echo "Release Notes" ;;
    style-guide)     echo "Style Guide" ;;
    glossary)        echo "Glossary" ;;
    explanation)     echo "Explanation" ;;
    *)               echo "$dir" ;;
  esac
}

# Map folder names to descriptions
description_of() {
  local dir="$1"
  case "$dir" in
    concept)         echo "Explanatory documents that build understanding of the portfolio architecture and methodology." ;;
    how-to)          echo "Step-by-step guides for common tasks across the danielvm-git portfolio." ;;
    tutorial)        echo "Tutorials and walkthroughs for learning and onboarding." ;;
    reference)       echo "Technical reference material — standards, rules, contracts, and specifications." ;;
    api-reference)   echo "API contract documentation for services and integrations." ;;
    troubleshooting) echo "Solutions for common issues and failures across the portfolio." ;;
    release-notes)   echo "Release history and changelog entries per release cycle." ;;
    style-guide)     echo "Writing and formatting standards for portfolio documentation." ;;
    glossary)        echo "Domain terminology and definitions used across the portfolio." ;;
    explanation)     echo "Background and explanatory content (legacy Diátaxis folder, kept for reference)." ;;
    *)               echo "Documentation for $dir." ;;
  esac
}

# Extract a field from YAML frontmatter in a file.
# Usage: get_frontmatter <file> <field>
get_frontmatter() {
  local file="$1"
  local field="$2"
  # Read lines between first and second "^---$"
  awk '
    /^---$/ { count++; next }
    count == 1 && /^'"$field"':/ {
      sub(/^[^:]+:[[:space:]]*/,"")
      gsub(/^["\x27]|["\x27]$/,"")
      print
      exit
    }
    count >= 2 { exit }
  ' "$file"
}

# Write index.md for a given docs/ subfolder.
generate_index() {
  local dir="$1"
  local heading
  local description
  heading=$(heading_of "$(basename "$dir")")
  description=$(description_of "$(basename "$dir")")

  local index_file="$dir/index.md"
  local tmp_file
  tmp_file=$(mktemp)

  # Write frontmatter
  cat > "$tmp_file" <<FRONTMATTER
---
type: Index
title: $heading
description: $description
tags: [index]
timestamp: $(date +%Y-%m-%d)
---

# $heading

FRONTMATTER

  # Collect .md files in this folder, excluding index.md and *-ref.md
  local count=0
  while IFS= read -r -d '' md_file; do
    local basename
    basename=$(basename "$md_file")

    # Skip index.md and *-ref.md files
    case "$basename" in
      index.md)  continue ;;
      *-ref.md)  continue ;;
    esac

    # Extract title and description from YAML frontmatter
    local title
    local desc
    title=$(get_frontmatter "$md_file" "title")
    desc=$(get_frontmatter "$md_file" "description")

    # Fallback if frontmatter fields are missing
    [ -z "$title" ] && title="${basename%.md}"
    [ -z "$desc" ]  && desc=""

    # OKF §6 format
    if [ -n "$desc" ]; then
      echo "* [$title]($basename) — $desc" >> "$tmp_file"
    else
      echo "* [$title]($basename)" >> "$tmp_file"
    fi
    count=$((count + 1))
  done < <(find "$dir" -maxdepth 1 -name '*.md' -type f -print0)

  if [ "$count" -eq 0 ]; then
    echo "" >> "$tmp_file"
    echo "_No documents yet in this section._" >> "$tmp_file"
  fi

  # Overwrite index.md atomically
  mv "$tmp_file" "$index_file"
  echo "  Generated: $(basename "$dir")/index.md ($count entries)"
}

echo "Generating doc indexes..."
echo ""

# Process each immediate subfolder of docs/
for subdir in "$DOCS_DIR"/*/; do
  [ -d "$subdir" ] || continue
  generate_index "$subdir"
done

echo ""
echo "All indexes generated successfully."
