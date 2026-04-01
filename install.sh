#!/usr/bin/env bash
# vibe-claude-setup installer
#
# Sets up:
#   1. ECC plugin (via submodule)
#   2. zh-TW rules
#   3. ECC auto-update scripts
#   4. CLAUDE.md global instructions
#   5. SessionStart hook for update notifications
#
# Safe: backs up existing files before overwriting.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"
ECC_DIR="$PLUGINS_DIR/everything-claude-code"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "=== vibe-claude-setup installer ==="
echo ""

# ─── Step 0: Prerequisites ─────────────────────────────────
if ! command -v node &>/dev/null; then
  echo "ERROR: node is required. Install Node.js first."
  exit 1
fi
if ! command -v git &>/dev/null; then
  echo "ERROR: git is required."
  exit 1
fi

mkdir -p "$CLAUDE_DIR/rules"
mkdir -p "$CLAUDE_DIR/scripts"
mkdir -p "$PLUGINS_DIR"

# ─── Step 1: Install ECC plugin ────────────────────────────
echo "[1/5] Installing ECC plugin..."
if [ -d "$ECC_DIR/.git" ]; then
  echo "  ECC already installed at $ECC_DIR, updating..."
  cd "$ECC_DIR" && git pull --ff-only origin main 2>&1 || echo "  WARNING: pull failed, using existing version"
  npm install --no-audit --no-fund --loglevel=error 2>&1
else
  if [ -d "$ECC_DIR" ]; then
    echo "  Backing up existing $ECC_DIR → $ECC_DIR.bak"
    mv "$ECC_DIR" "$ECC_DIR.bak"
  fi
  git clone https://github.com/affaan-m/everything-claude-code.git "$ECC_DIR"
  cd "$ECC_DIR" && npm install --no-audit --no-fund --loglevel=error 2>&1
fi
echo "  ECC version: $(cat "$ECC_DIR/VERSION" 2>/dev/null || echo "unknown")"

# ─── Step 2: Install zh-TW rules ──────────────────────────
echo "[2/5] Installing zh-TW rules..."
if [ -d "$CLAUDE_DIR/rules/zh" ]; then
  echo "  Backing up existing zh rules → zh.bak"
  mv "$CLAUDE_DIR/rules/zh" "$CLAUDE_DIR/rules/zh.bak"
fi
cp -R "$SCRIPT_DIR/rules/zh" "$CLAUDE_DIR/rules/zh"
echo "  Installed to $CLAUDE_DIR/rules/zh/"

# Also install common rules from ECC if not present
if [ ! -d "$CLAUDE_DIR/rules/common" ]; then
  echo "  Installing common rules from ECC..."
  cd "$ECC_DIR" && bash install.sh 2>&1 || echo "  WARNING: ECC install.sh failed, common rules may be missing"
fi

# ─── Step 3: Install auto-update scripts ───────────────────
echo "[3/5] Installing auto-update scripts..."
for script in ecc-update-check.sh ecc-update-hook.js ecc-upgrade.sh; do
  cp "$SCRIPT_DIR/scripts/$script" "$CLAUDE_DIR/scripts/$script"
done
chmod +x "$CLAUDE_DIR/scripts/ecc-update-check.sh" "$CLAUDE_DIR/scripts/ecc-upgrade.sh"
echo "  Installed 3 scripts to $CLAUDE_DIR/scripts/"

# ─── Step 4: Install CLAUDE.md ─────────────────────────────
echo "[4/5] Installing CLAUDE.md..."
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  echo "  Backing up existing CLAUDE.md → CLAUDE.md.bak"
  cp "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md.bak"
fi
cp "$SCRIPT_DIR/CLAUDE.md.template" "$CLAUDE_DIR/CLAUDE.md"
echo "  Installed to $CLAUDE_DIR/CLAUDE.md"

# ─── Step 5: Add SessionStart hook ─────────────────────────
echo "[5/5] Configuring SessionStart hook..."
HOOK_CMD="node ~/.claude/scripts/ecc-update-hook.js"

if [ -f "$SETTINGS_FILE" ]; then
  # Check if hook already exists
  if grep -q "ecc-update-hook" "$SETTINGS_FILE" 2>/dev/null; then
    echo "  Hook already configured, skipping."
  else
    echo "  NOTE: Please add this to your settings.json manually under hooks.SessionStart:"
    echo ""
    echo '    {'
    echo '      "matcher": "*",'
    echo '      "hooks": [{'
    echo '        "type": "command",'
    echo "        \"command\": \"$HOOK_CMD\","
    echo '        "timeout": 15'
    echo '      }]'
    echo '    }'
    echo ""
    echo "  Or run: claude /update-config to manage hooks."
  fi
else
  echo "  No settings.json found. Run ECC's install.sh first to generate it."
  echo "  Then re-run this installer to add the update hook."
fi

# ─── Done ──────────────────────────────────────────────────
echo ""
echo "=== Installation complete ==="
echo ""
echo "What was installed:"
echo "  - ECC plugin:      $ECC_DIR"
echo "  - zh-TW rules:     $CLAUDE_DIR/rules/zh/"
echo "  - Update scripts:  $CLAUDE_DIR/scripts/ecc-update-*"
echo "  - CLAUDE.md:       $CLAUDE_DIR/CLAUDE.md"
echo ""
echo "Next steps:"
echo "  1. Start a new Claude Code session to verify"
echo "  2. Run 'bash ~/.claude/scripts/ecc-update-check.sh --force' to test update check"
echo "  3. Customize $CLAUDE_DIR/CLAUDE.md to your preferences"
echo ""
echo "Happy vibing!"
