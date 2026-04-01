# vibe-claude-setup

Claude Code 繁中友善設定包。基於 [Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code)，加上：

- 繁體中文規則翻譯（`rules/zh/`）
- ECC 自動更新通知（lazy check，不是 cron）
- 預設全域指令（`CLAUDE.md`）

## 快速安裝

```bash
git clone --recursive https://github.com/frankekn/vibe-claude-setup.git
cd vibe-claude-setup
./install.sh
```

如果忘了 `--recursive`：

```bash
git submodule update --init
```

## 包含什麼

```
vibe-claude-setup/
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
└── ecc/                    # ECC (git submodule)
```

## 自動更新機制

每次開新 Claude Code session 時自動檢查 ECC 是否有新版本：

- **快取 60 分鐘**，不會每次都去 GitHub fetch
- 偵測到新版 → 用 `AskUserQuestion` 互動式詢問
- 四個選項：立即升級 / 自動升級 / 稍後提醒 / 不再詢問
- Snooze 遞增靜默：24h → 48h → 7 天
- 只用 `git pull --ff-only`，不會強制覆蓋
- **不影響你的客製化**（rules、settings 等在 ECC 目錄外）

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
cd vibe-claude-setup
git pull
git submodule update --remote
./install.sh
```

## 前置需求

- [Node.js](https://nodejs.org/) (v18+)
- [Git](https://git-scm.com/)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)

## License

MIT
