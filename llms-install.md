# claude-forge — Installation Guide for LLM Agents

You are an AI coding agent. Follow these steps to install claude-forge for the user.

## What is claude-forge?

A configuration toolkit for Claude Code built on Everything Claude Code (ECC). It includes:
- Localized rules (zh-TW translations)
- ECC auto-update mechanism (lazy check on session start)
- Pre-configured CLAUDE.md with global defaults

## Prerequisites

- Node.js v18+
- Git
- Claude Code CLI

## Step-by-Step Installation

### Step 1: Clone the repository

```bash
git clone --recursive https://github.com/frankekn/claude-forge.git ~/.claude-forge
```

### Step 2: Run the installer

```bash
cd ~/.claude-forge && ./install.sh
```

This will:
1. Install ECC plugin to `~/.claude/plugins/everything-claude-code/`
2. Install zh-TW rules to `~/.claude/rules/zh/`
3. Install auto-update scripts to `~/.claude/scripts/`
4. Install CLAUDE.md to `~/.claude/CLAUDE.md` (backs up existing)
5. Configure SessionStart hook for update notifications

### Step 3: Add the SessionStart hook

If the installer could not auto-configure the hook, add this to `~/.claude/settings.json` under `hooks.SessionStart`:

```json
{
  "matcher": "*",
  "hooks": [{
    "type": "command",
    "command": "node ~/.claude/scripts/ecc-update-hook.js",
    "timeout": 15
  }]
}
```

### Step 4: Verify installation

```bash
bash ~/.claude/scripts/ecc-update-check.sh --force
```

If it outputs nothing or `UP_TO_DATE`, the installation is successful.

## Post-Install

- Edit `~/.claude/CLAUDE.md` to customize language and preferences
- Start a new Claude Code session to verify everything works
- The auto-update check runs on each session start (cached for 60 minutes)

## Important Notes

- The installer backs up existing files before overwriting (`.bak` suffix)
- User customizations in `~/.claude/rules/` and `~/.claude/settings.json` are NOT affected by ECC updates
- Auto-updates use `git pull --ff-only` — conflicts are never forced

## Credits

- [Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code) by Affaan M
- [gstack](https://github.com/garrytan/gstack) by Garry Tan
