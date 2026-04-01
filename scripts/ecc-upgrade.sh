#!/usr/bin/env bash
# ecc-upgrade — Upgrade Everything Claude Code plugin.
#
# Safe upgrade flow:
#   1. git pull --ff-only (won't force if conflicts)
#   2. npm install
#   3. Write marker for "just upgraded" notification
#
# This ONLY touches ~/.claude/plugins/everything-claude-code/
# User customizations in ~/.claude/rules/, ~/.claude/settings.json, etc. are NOT affected.
set -euo pipefail

ECC_DIR="${ECC_PLUGIN_DIR:-$HOME/.claude/plugins/everything-claude-code}"
STATE_DIR="${ECC_STATE_DIR:-$HOME/.claude/.ecc-state}"

mkdir -p "$STATE_DIR"

if [ ! -d "$ECC_DIR/.git" ]; then
  echo "ERROR: $ECC_DIR is not a git repo"
  exit 1
fi

cd "$ECC_DIR"

# Save old version
OLD_VERSION=$(cat VERSION 2>/dev/null | tr -d '[:space:]' || echo "unknown")

# Check for local modifications
STASH_OUTPUT=""
if [ -n "$(git status --porcelain)" ]; then
  echo "NOTE: Local modifications detected, stashing..."
  STASH_OUTPUT=$(git stash push -m "auto-stash before ECC upgrade $(date +%Y%m%d)" 2>&1)
fi

# Pull (ff-only for safety)
if ! git pull --ff-only origin main 2>&1; then
  echo "ERROR: fast-forward pull failed. Manual intervention needed."
  if echo "$STASH_OUTPUT" | grep -q "Saved working directory"; then
    echo "Restoring stashed changes..."
    git stash pop 2>/dev/null || true
  fi
  exit 1
fi

NEW_VERSION=$(cat VERSION 2>/dev/null | tr -d '[:space:]' || echo "unknown")

# Install dependencies
npm install --no-audit --no-fund --loglevel=error 2>&1

# Write upgrade marker + clear cache
if [ "$OLD_VERSION" != "$NEW_VERSION" ]; then
  echo "$OLD_VERSION" > "$STATE_DIR/just-upgraded-from"
  rm -f "$STATE_DIR/last-update-check"
  rm -f "$STATE_DIR/update-snoozed"
  echo "Upgraded ECC: v$OLD_VERSION -> v$NEW_VERSION"
else
  echo "Already up to date: v$NEW_VERSION"
fi

# Warn about stashed changes
if echo "$STASH_OUTPUT" | grep -q "Saved working directory"; then
  echo "WARNING: Local changes were stashed. Run 'cd $ECC_DIR && git stash pop' to restore."
fi
