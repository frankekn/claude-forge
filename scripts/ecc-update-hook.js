#!/usr/bin/env node
/**
 * ECC Update Check — SessionStart hook
 *
 * Runs ecc-update-check.sh on session start and injects the result
 * into Claude's context so it can prompt the user about upgrades.
 *
 * This file lives OUTSIDE the ECC plugin directory, so it won't be
 * overwritten when ECC updates itself.
 */
const { execFileSync } = require('child_process');
const path = require('path');

function main() {
  // Pass through stdin (required by hook protocol)
  let stdin = '';
  try {
    stdin = require('fs').readFileSync(0, 'utf8');
  } catch {}

  const checkScript = path.join(__dirname, 'ecc-update-check.sh');
  let output = '';
  try {
    output = execFileSync('bash', [checkScript], {
      encoding: 'utf8',
      timeout: 10000,
    }).trim();
  } catch {
    // Silent fail — don't block session start
  }

  // Check if auto-upgrade is enabled
  const fs = require('fs');
  const autoUpgradeFile = path.join(
    process.env.HOME || require('os').homedir(),
    '.claude', '.ecc-state', 'auto-upgrade'
  );
  let autoUpgrade = false;
  try {
    autoUpgrade = fs.readFileSync(autoUpgradeFile, 'utf8').trim() === 'true';
  } catch {}

  if (autoUpgrade && output && output.includes('ECC_UPGRADE_AVAILABLE')) {
    const parts = output.split(/\s+/);
    const oldVer = parts[1] || '?';
    const newVer = parts[2] || '?';

    // Auto-upgrade: run the upgrade script directly
    let upgradeOutput = '';
    try {
      const upgradeScript = path.join(__dirname, 'ecc-upgrade.sh');
      upgradeOutput = execFileSync('bash', [upgradeScript], {
        encoding: 'utf8',
        timeout: 60000,
      }).trim();
    } catch (e) {
      upgradeOutput = `Auto-upgrade failed: ${e.message}`;
    }

    const msg = `[ECC Auto-Upgrade] v${oldVer} → v${newVer}\n${upgradeOutput}\nRead ~/.claude/plugins/everything-claude-code/CHANGELOG.md and summarize what's new in 5-7 bullets.`;
    process.stdout.write(JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'SessionStart',
        additionalContext: msg
      }
    }));
  } else if (output && output.includes('ECC_UPGRADE_AVAILABLE')) {
    const parts = output.split(/\s+/);
    const oldVer = parts[1] || '?';
    const newVer = parts[2] || '?';
    const msg = [
      `[ECC Update] Everything Claude Code **v${newVer}** is available (current: v${oldVer}).`,
      '',
      'IMPORTANT: You MUST use AskUserQuestion to ask the user before proceeding:',
      `- Question: "Everything Claude Code **v${newVer}** 已可更新（目前版本 v${oldVer}）。要現在升級嗎？"`,
      '- Options: ["Yes, upgrade now", "Always auto-upgrade", "Not now", "Never ask again"]',
      '',
      'Handle each response:',
      '',
      '**"Yes, upgrade now":** Run `bash ~/.claude/scripts/ecc-upgrade.sh` and show the output.',
      '',
      '**"Always auto-upgrade":** Run these commands:',
      '  mkdir -p ~/.claude/.ecc-state',
      '  echo "true" > ~/.claude/.ecc-state/auto-upgrade',
      '  Then run `bash ~/.claude/scripts/ecc-upgrade.sh`.',
      '  Tell user: "Auto-upgrade enabled. Future updates will install automatically."',
      '',
      '**"Not now":** Run this snooze script:',
      '  ```bash',
      `  _SNOOZE_FILE=~/.claude/.ecc-state/update-snoozed`,
      `  _REMOTE_VER="${newVer}"`,
      '  _CUR_LEVEL=0',
      '  if [ -f "$_SNOOZE_FILE" ]; then',
      '    _SNOOZED_VER=$(awk \'{print $1}\' "$_SNOOZE_FILE")',
      '    if [ "$_SNOOZED_VER" = "$_REMOTE_VER" ]; then',
      '      _CUR_LEVEL=$(awk \'{print $2}\' "$_SNOOZE_FILE")',
      '    fi',
      '  fi',
      '  _NEW_LEVEL=$((_CUR_LEVEL + 1))',
      '  [ "$_NEW_LEVEL" -gt 3 ] && _NEW_LEVEL=3',
      '  echo "$_REMOTE_VER $_NEW_LEVEL $(date +%s)" > "$_SNOOZE_FILE"',
      '  ```',
      '  Tell user the snooze duration (level 1=24h, 2=48h, 3+=7 days).',
      '',
      '**"Never ask again":** Run:',
      '  touch ~/.claude/.ecc-state/update-disabled',
      '  Tell user: "Update checks disabled. Delete ~/.claude/.ecc-state/update-disabled to re-enable."',
      '',
      'Note: User customizations in ~/.claude/rules/ and ~/.claude/settings.json are NOT affected by upgrades.',
    ].join('\n');

    process.stdout.write(JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'SessionStart',
        additionalContext: msg
      }
    }));
  } else if (output && output.includes('ECC_JUST_UPGRADED')) {
    const parts = output.split(/\s+/);
    const oldVer = parts[1] || '?';
    const newVer = parts[2] || '?';
    const msg = `[ECC Update] Everything Claude Code was just upgraded: v${oldVer} → v${newVer}! Read ~/.claude/plugins/everything-claude-code/CHANGELOG.md and summarize what's new in 5-7 bullets.`;

    process.stdout.write(JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'SessionStart',
        additionalContext: msg
      }
    }));
  } else {
    // Up to date — pass through original stdin
    process.stdout.write(stdin);
  }
}

main();
