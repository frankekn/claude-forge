#!/usr/bin/env bash
# ecc-update-check — lazy version check for Everything Claude Code plugin.
#
# Modeled after gstack's update-check mechanism:
#   - Runs on session start (not cron)
#   - Caches results to avoid repeated GitHub fetches
#   - Supports snooze with escalating backoff
#
# Output (one line, or nothing):
#   ECC_UPGRADE_AVAILABLE <old> <new>  — remote VERSION differs from local
#   ECC_JUST_UPGRADED <old> <new>      — marker found from recent upgrade
#   (nothing)                          — up to date, snoozed, or check skipped
#
# Env overrides (for testing):
#   ECC_PLUGIN_DIR      — override plugin directory
#   ECC_STATE_DIR       — override state directory
#   ECC_REMOTE_URL      — override remote VERSION URL
set -euo pipefail

ECC_DIR="${ECC_PLUGIN_DIR:-$HOME/.claude/plugins/everything-claude-code}"
STATE_DIR="${ECC_STATE_DIR:-$HOME/.claude/.ecc-state}"
CACHE_FILE="$STATE_DIR/last-update-check"
MARKER_FILE="$STATE_DIR/just-upgraded-from"
SNOOZE_FILE="$STATE_DIR/update-snoozed"
VERSION_FILE="$ECC_DIR/VERSION"
REMOTE_URL="${ECC_REMOTE_URL:-https://raw.githubusercontent.com/affaan-m/everything-claude-code/main/VERSION}"

# ─── Force flag (busts cache + snooze) ──────────────────────
if [ "${1:-}" = "--force" ]; then
  rm -f "$CACHE_FILE"
  rm -f "$SNOOZE_FILE"
fi

# ─── Step 0: Check if updates are disabled ──────────────────
if [ -f "$STATE_DIR/update-disabled" ]; then
  exit 0
fi

# ─── Snooze helper ──────────────────────────────────────────
check_snooze() {
  local remote_ver="$1"
  if [ ! -f "$SNOOZE_FILE" ]; then
    return 1
  fi
  local snoozed_ver snoozed_level snoozed_epoch
  snoozed_ver="$(awk '{print $1}' "$SNOOZE_FILE" 2>/dev/null || true)"
  snoozed_level="$(awk '{print $2}' "$SNOOZE_FILE" 2>/dev/null || true)"
  snoozed_epoch="$(awk '{print $3}' "$SNOOZE_FILE" 2>/dev/null || true)"

  if [ -z "$snoozed_ver" ] || [ -z "$snoozed_level" ] || [ -z "$snoozed_epoch" ]; then
    return 1
  fi
  case "$snoozed_level" in *[!0-9]*) return 1 ;; esac
  case "$snoozed_epoch" in *[!0-9]*) return 1 ;; esac

  # New version resets snooze
  if [ "$snoozed_ver" != "$remote_ver" ]; then
    return 1
  fi

  local duration
  case "$snoozed_level" in
    1) duration=86400 ;;   # 24h
    2) duration=172800 ;;  # 48h
    *) duration=604800 ;;  # 7 days
  esac

  local now
  now="$(date +%s)"
  local expires=$(( snoozed_epoch + duration ))
  if [ "$now" -lt "$expires" ]; then
    return 0  # still snoozed
  fi
  return 1
}

# ─── Step 1: Read local version ─────────────────────────────
LOCAL=""
if [ -f "$VERSION_FILE" ]; then
  LOCAL="$(cat "$VERSION_FILE" 2>/dev/null | tr -d '[:space:]')"
fi
if [ -z "$LOCAL" ]; then
  exit 0
fi

# ─── Step 2: Check "just upgraded" marker ────────────────────
if [ -f "$MARKER_FILE" ]; then
  OLD="$(cat "$MARKER_FILE" 2>/dev/null | tr -d '[:space:]')"
  rm -f "$MARKER_FILE"
  rm -f "$SNOOZE_FILE"
  if [ -n "$OLD" ]; then
    echo "ECC_JUST_UPGRADED $OLD $LOCAL"
  fi
fi

# ─── Step 3: Check cache freshness ──────────────────────────
if [ -f "$CACHE_FILE" ]; then
  CACHED="$(cat "$CACHE_FILE" 2>/dev/null || true)"
  case "$CACHED" in
    UP_TO_DATE*)        CACHE_TTL=60 ;;
    UPGRADE_AVAILABLE*) CACHE_TTL=720 ;;
    *)                  CACHE_TTL=0 ;;
  esac

  STALE=$(find "$CACHE_FILE" -mmin +$CACHE_TTL 2>/dev/null || true)
  if [ -z "$STALE" ] && [ "$CACHE_TTL" -gt 0 ]; then
    case "$CACHED" in
      UP_TO_DATE*)
        CACHED_VER="$(echo "$CACHED" | awk '{print $2}')"
        if [ "$CACHED_VER" = "$LOCAL" ]; then
          exit 0
        fi
        ;;
      UPGRADE_AVAILABLE*)
        CACHED_OLD="$(echo "$CACHED" | awk '{print $2}')"
        if [ "$CACHED_OLD" = "$LOCAL" ]; then
          CACHED_NEW="$(echo "$CACHED" | awk '{print $3}')"
          if check_snooze "$CACHED_NEW"; then
            exit 0
          fi
          echo "ECC_UPGRADE_AVAILABLE $LOCAL $CACHED_NEW"
          exit 0
        fi
        ;;
    esac
  fi
fi

# ─── Step 4: Fetch remote version ───────────────────────────
mkdir -p "$STATE_DIR"

REMOTE=""
REMOTE="$(curl -sf --max-time 5 "$REMOTE_URL" 2>/dev/null || true)"
REMOTE="$(echo "$REMOTE" | tr -d '[:space:]')"

# Validate version format
if ! echo "$REMOTE" | grep -qE '^[0-9]+\.[0-9.]+$'; then
  echo "UP_TO_DATE $LOCAL" > "$CACHE_FILE"
  exit 0
fi

if [ "$LOCAL" = "$REMOTE" ]; then
  echo "UP_TO_DATE $LOCAL" > "$CACHE_FILE"
  exit 0
fi

# Versions differ
echo "UPGRADE_AVAILABLE $LOCAL $REMOTE" > "$CACHE_FILE"
if check_snooze "$REMOTE"; then
  exit 0
fi

echo "ECC_UPGRADE_AVAILABLE $LOCAL $REMOTE"
