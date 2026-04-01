# claude-forge

A Traditional Chinese (zh-TW) friendly configuration pack for [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Built on top of [Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code) and inspired by [gstack](https://github.com/garrytan/gstack)'s update mechanism.

Claude Code 繁體中文友善設定包。基於 [Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code) 打造，自動更新機制參考 [gstack](https://github.com/garrytan/gstack) 的設計。

---

## Features / 功能

- **zh-TW Rules** — Traditional Chinese translations for all common rules (coding style, testing, security, git workflow, etc.)
- **ECC Auto-Update** — Lazy version check on session start (not cron), with interactive upgrade prompts
- **Global Defaults** — Pre-configured `CLAUDE.md` with zh-TW language preference and ECC/gstack integration

---

- **繁中規則翻譯** — 所有通用規則的繁體中文翻譯（coding style、testing、security、git workflow 等）
- **ECC 自動更新** — Session 啟動時 lazy check（不是 cron），互動式升級提示
- **全域預設** — 預先設定好的 `CLAUDE.md`，包含繁中語言偏好及 ECC/gstack 整合

## Quick Start / 快速安裝

```bash
git clone --recursive https://github.com/frankekn/claude-forge.git
cd claude-forge
./install.sh
```

If you forgot `--recursive` / 如果忘了 `--recursive`：

```bash
git submodule update --init
```

## What's Included / 包含什麼

```
claude-forge/
├── install.sh              # One-click installer / 一鍵安裝
├── CLAUDE.md.template      # Global instructions template / 全域指令模板
├── rules/zh/               # zh-TW rule translations / 繁中規則翻譯
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
│   ├── ecc-update-check.sh # Version check (on session start) / 版本檢查
│   ├── ecc-update-hook.js  # SessionStart hook
│   └── ecc-upgrade.sh      # Upgrade script / 升級腳本
├── settings.json.template  # Hook config reference / Hook 設定參考
└── ecc/                    # ECC (git submodule)
```

## Auto-Update Mechanism / 自動更新機制

Automatically checks for ECC updates on each new Claude Code session:

每次開新 Claude Code session 時自動檢查 ECC 是否有新版本：

- **60-minute cache** — won't fetch from GitHub on every session / 快取 60 分鐘，不會每次都 fetch
- **Interactive prompt** — uses `AskUserQuestion` with 4 options / 用 `AskUserQuestion` 互動式詢問
  - Upgrade now / 立即升級
  - Always auto-upgrade / 自動升級
  - Not now (snooze) / 稍後提醒
  - Never ask again / 不再詢問
- **Escalating snooze** — 24h → 48h → 7 days / Snooze 遞增靜默
- **Safe upgrades** — `git pull --ff-only`, won't force on conflicts / 不會強制覆蓋
- **Won't touch your customizations** — rules, settings live outside the ECC directory / 不影響你的客製化

Update mechanism design inspired by [gstack](https://github.com/garrytan/gstack)'s `gstack-update-check`.

自動更新機制設計靈感來自 [gstack](https://github.com/garrytan/gstack) 的 `gstack-update-check`。

### Manual Operations / 手動操作

```bash
# Force check / 強制檢查一次
bash ~/.claude/scripts/ecc-update-check.sh --force

# Manual upgrade / 手動升級
bash ~/.claude/scripts/ecc-upgrade.sh

# Disable/enable update checks / 停用/啟用更新檢查
touch ~/.claude/.ecc-state/update-disabled    # Disable / 停用
rm ~/.claude/.ecc-state/update-disabled       # Enable / 啟用
```

## Updating This Pack / 更新此設定包

```bash
cd claude-forge
git pull
git submodule update --remote
./install.sh
```

## Prerequisites / 前置需求

- [Node.js](https://nodejs.org/) (v18+)
- [Git](https://git-scm.com/)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)

## Credits / 致謝

This project stands on the shoulders of:

本專案建立在以下優秀開源專案之上：

- **[Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code)** by [Affaan M](https://github.com/affaan-m) — The comprehensive Claude Code plugin framework that powers this setup. Rules, agents, hooks, skills, and commands are all managed by ECC.

  ECC 是驅動整個設定的核心框架，提供了完整的 rules、agents、hooks、skills 和 commands 管理系統。

- **[gstack](https://github.com/garrytan/gstack)** by [Garry Tan](https://github.com/garrytan) — The auto-update mechanism in this project (lazy version check, cache TTL, snooze with escalating backoff, interactive upgrade prompts) is directly modeled after gstack's elegant `gstack-update-check` design.

  本專案的自動更新機制（lazy check、快取 TTL、遞增靜默、互動式升級提示）直接參考了 gstack 的 `gstack-update-check` 設計。

## License

MIT
