#!/usr/bin/env bash
# pull-brand-tokens.sh — copy design tokens from brand_identity_danielvm into a project
#
# Usage: ./scripts/pull-brand-tokens.sh <target-dir>
#   target-dir  Project root to copy tokens into (e.g. ~/Developer/my-project)

set -euo pipefail

TARGET="${1:?Usage: pull-brand-tokens.sh <target-dir>}"
BRAND_REPO="$HOME/Developer/brand_identity_danielvm"

if [ ! -d "$BRAND_REPO" ]; then
  echo "::error::brand_identity_danielvm not found at $BRAND_REPO — clone it first"
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "::error::target directory $TARGET does not exist"
  exit 1
fi

# Copy tokens.css if it exists
if [ -f "$BRAND_REPO/tokens.css" ]; then
  mkdir -p "$TARGET/src/styles"
  cp "$BRAND_REPO/tokens.css" "$TARGET/src/styles/tokens.css"
  echo "✅ Copied tokens.css → $TARGET/src/styles/tokens.css"
else
  echo "⚠️  tokens.css not found in brand_identity_danielvm — check repo structure"
fi

# Copy brand assets if they exist
if [ -d "$BRAND_REPO/assets" ]; then
  mkdir -p "$TARGET/public/brand"
  cp -r "$BRAND_REPO/assets/"* "$TARGET/public/brand/" 2>/dev/null || true
  echo "✅ Copied brand assets → $TARGET/public/brand/"
fi

echo "Done. Imported brand tokens into $TARGET"
