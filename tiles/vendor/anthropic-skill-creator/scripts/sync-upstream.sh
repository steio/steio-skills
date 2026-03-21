#!/bin/bash
# Sync skill-creator from upstream Anthropic repository
# Usage: ./scripts/sync-upstream.sh [--dry-run]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TILE_DIR="$(dirname "$SCRIPT_DIR")"
UPSTREAM_REPO="https://github.com/anthropics/skills.git"
UPSTREAM_PATH="skills/skill-creator"
TEMP_DIR=$(mktemp -d)

DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "🔍 DRY RUN - no changes will be made"
fi

echo "📥 Fetching upstream..."
cd "$TEMP_DIR"
git clone --depth 1 --filter=blob:none --sparse "$UPSTREAM_REPO" upstream 2>/dev/null
cd upstream
git sparse-checkout set "$UPSTREAM_PATH" 2>/dev/null

UPSTREAM_COMMIT=$(git rev-parse HEAD)
echo "   Upstream commit: $UPSTREAM_COMMIT"

# Check if already synced
CURRENT_COMMIT=$(cat "$TILE_DIR/tile.json" | grep -o '"commit": "[^"]*"' | cut -d'"' -f4 || echo "none")
if [[ "$CURRENT_COMMIT" == "$UPSTREAM_COMMIT" ]]; then
  echo "✅ Already up to date (commit: $UPSTREAM_COMMIT)"
  rm -rf "$TEMP_DIR"
  exit 0
fi

echo "🔄 Changes detected:"
echo "   Current: $CURRENT_COMMIT"
echo "   Upstream: $UPSTREAM_COMMIT"

# Show diff
if command -v diff &> /dev/null; then
  echo ""
  echo "📋 Changed files:"
  diff -rq "$TILE_DIR/skills/skill-creator" "$UPSTREAM_PATH" 2>/dev/null || true
fi

if $DRY_RUN; then
  echo ""
  echo "🔍 Dry run complete. Run without --dry-run to apply changes."
  rm -rf "$TEMP_DIR"
  exit 0
fi

# Apply changes
echo ""
echo "📝 Applying changes..."
rm -rf "$TILE_DIR/skills/skill-creator"/*
cp -r "$UPSTREAM_PATH"/* "$TILE_DIR/skills/skill-creator/"

# Update tile.json with new commit
if command -v jq &> /dev/null; then
  jq --arg commit "$UPSTREAM_COMMIT" \
     --arg date "$(date +%Y-%m-%d)" \
     '._upstream.commit = $commit | ._upstream.synced_at = $date' \
     "$TILE_DIR/tile.json" > "$TILE_DIR/tile.json.tmp" && mv "$TILE_DIR/tile.json.tmp" "$TILE_DIR/tile.json"
else
  sed -i "s/\"commit\": \"[^\"]*\"/\"commit\": \"$UPSTREAM_COMMIT\"/" "$TILE_DIR/tile.json"
  sed -i "s/\"synced_at\": \"[^\"]*\"/\"synced_at\": \"$(date +%Y-%m-%d)\"/" "$TILE_DIR/tile.json"
fi

# Update AGENTS.md
sed -i "s/Commit: .*/Commit: $UPSTREAM_COMMIT/" "$TILE_DIR/AGENTS.md"
sed -i "s/Synced: .*/Synced: $(date +%Y-%m-%d)/" "$TILE_DIR/AGENTS.md"

echo "✅ Sync complete!"
echo "   Commit: $UPSTREAM_COMMIT"
echo ""
echo "⚠️  Remember to:"
echo "   1. Review changes in skills/skill-creator/"
echo "   2. Update version in tile.json if needed"
echo "   3. Commit and push"

rm -rf "$TEMP_DIR"