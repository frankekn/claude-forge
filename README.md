# claude-forge

![claude-forge banner](assets/banner.jpg)

**[English](README.md)** | [繁體中文](README.zh-TW.md) | [简体中文](README.zh-CN.md)

A configuration toolkit for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Built on top of [Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code), with auto-update mechanism inspired by [gstack](https://github.com/garrytan/gstack).

## Features

- **Localized Rules** — Translated rule sets for non-English speakers (zh-TW included, more welcome)
- **ECC Auto-Update** — Lazy version check on session start (not cron), with interactive upgrade prompts
- **Global Defaults** — Pre-configured `CLAUDE.md` with language preferences and ECC/gstack integration
- **One-Click Install** — Single script sets up everything

## Quick Start

```bash
git clone --recursive https://github.com/frankekn/claude-forge.git
cd claude-forge
./install.sh
```

If you forgot `--recursive`:

```bash
git submodule update --init
```

## What's Included

```
claude-forge/
├── install.sh              # One-click installer
├── CLAUDE.md.template      # Global instructions template
├── rules/zh/               # zh-TW rule translations
│   ├── coding-style.md
│   ├── testing.md
│   ├── security.md
│   ├── git-workflow.md
│   ├── performance.md
│   ├── patterns.md
│   ├── hooks.md
│   ├── agents.md
│   ├── code-review.md
│   └── development-workflow.md
├── scripts/
│   ├── ecc-update-check.sh # Version check (on session start)
│   ├── ecc-update-hook.js  # SessionStart hook
│   └── ecc-upgrade.sh      # Upgrade script
├── settings.json.template  # Hook config reference
└── ecc/                    # ECC (git submodule)
```

## Auto-Update Mechanism

Automatically checks for ECC updates on each new Claude Code session:

- **60-minute cache** — won't fetch from GitHub on every session
- **Interactive prompt** — uses `AskUserQuestion` with 4 options:
  - Upgrade now
  - Always auto-upgrade
  - Not now (snooze)
  - Never ask again
- **Escalating snooze** — 24h → 48h → 7 days
- **Safe upgrades** — `git pull --ff-only`, won't force on conflicts
- **Won't touch your customizations** — rules and settings live outside the ECC directory

Update mechanism design inspired by [gstack](https://github.com/garrytan/gstack)'s `gstack-update-check`.

### Manual Operations

```bash
# Force a version check
bash ~/.claude/scripts/ecc-update-check.sh --force

# Manual upgrade
bash ~/.claude/scripts/ecc-upgrade.sh

# Disable/enable update checks
touch ~/.claude/.ecc-state/update-disabled    # Disable
rm ~/.claude/.ecc-state/update-disabled       # Enable
```

## Updating This Pack

```bash
cd claude-forge
git pull
git submodule update --remote
./install.sh
```

## For LLM Agents

Fetch the installation guide and follow it:

```
curl -s https://raw.githubusercontent.com/frankekn/claude-forge/main/llms-install.md
```

## Prerequisites

- [Node.js](https://nodejs.org/) (v18+)
- [Git](https://git-scm.com/)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)

## Credits

This project stands on the shoulders of:

- **[Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code)** by [Affaan M](https://github.com/affaan-m) — The comprehensive Claude Code plugin framework that powers this setup. Rules, agents, hooks, skills, and commands are all managed by ECC.

- **[gstack](https://github.com/garrytan/gstack)** by [Garry Tan](https://github.com/garrytan) — The auto-update mechanism (lazy version check, cache TTL, snooze with escalating backoff, interactive upgrade prompts) is directly modeled after gstack's elegant `gstack-update-check` design.

## License

MIT
