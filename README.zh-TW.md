# claude-forge

![claude-forge banner](assets/banner.jpg)

[English](README.md) | **[繁體中文](README.zh-TW.md)** | [简体中文](README.zh-CN.md)

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) 設定工具包。基於 [Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code) 打造，自動更新機制參考 [gstack](https://github.com/garrytan/gstack) 的設計。

## 功能

- **在地化規則** — 非英語使用者的翻譯規則集（已包含 zh-TW，歡迎貢獻更多語言）
- **ECC 自動更新** — Session 啟動時 lazy check（不是 cron），互動式升級提示
- **全域預設** — 預先設定好的 `CLAUDE.md`，包含語言偏好及 ECC/gstack 整合
- **一鍵安裝** — 一個腳本搞定所有設定

## 快速安裝

```bash
git clone --recursive https://github.com/frankekn/claude-forge.git
cd claude-forge
./install.sh
```

如果忘了 `--recursive`：

```bash
git submodule update --init
```

## 包含什麼

```
claude-forge/
├── install.sh              # 一鍵安裝
├── CLAUDE.md.template      # 全域指令模板
├── rules/zh/               # 繁中規則翻譯
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
│   ├── ecc-update-check.sh # 版本檢查（session 啟動時）
│   ├── ecc-update-hook.js  # SessionStart hook
│   └── ecc-upgrade.sh      # 升級腳本
├── settings.json.template  # Hook 設定參考
└── ecc/                    # ECC（git submodule）
```

## 自動更新機制

每次開新 Claude Code session 時自動檢查 ECC 是否有新版本：

- **快取 60 分鐘** — 不會每次都去 GitHub fetch
- **互動式提示** — 用 `AskUserQuestion` 提供 4 個選項：
  - 立即升級
  - 自動升級
  - 稍後提醒（snooze）
  - 不再詢問
- **遞增靜默** — 24 小時 → 48 小時 → 7 天
- **安全升級** — `git pull --ff-only`，有衝突不會強制覆蓋
- **不影響客製化** — 你的 rules、settings 在 ECC 目錄外，不受影響

自動更新機制設計靈感來自 [gstack](https://github.com/garrytan/gstack) 的 `gstack-update-check`。

### 手動操作

```bash
# 強制檢查一次
bash ~/.claude/scripts/ecc-update-check.sh --force

# 手動升級
bash ~/.claude/scripts/ecc-upgrade.sh

# 停用/啟用更新檢查
touch ~/.claude/.ecc-state/update-disabled    # 停用
rm ~/.claude/.ecc-state/update-disabled       # 啟用
```

## 更新此設定包

```bash
cd claude-forge
git pull
git submodule update --remote
./install.sh
```

## 前置需求

- [Node.js](https://nodejs.org/) (v18+)
- [Git](https://git-scm.com/)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)

## 致謝

本專案建立在以下優秀開源專案之上：

- **[Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code)** by [Affaan M](https://github.com/affaan-m) — 驅動整個設定的核心框架，提供完整的 rules、agents、hooks、skills 和 commands 管理系統。

- **[gstack](https://github.com/garrytan/gstack)** by [Garry Tan](https://github.com/garrytan) — 本專案的自動更新機制（lazy check、快取 TTL、遞增靜默、互動式升級提示）直接參考了 gstack 的 `gstack-update-check` 設計。

## 授權

MIT
