# claude-forge

![claude-forge banner](assets/banner.jpg)

[English](README.md) | [繁體中文](README.zh-TW.md) | **[简体中文](README.zh-CN.md)**

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) 配置工具包。基于 [Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code) 构建，自动更新机制参考 [gstack](https://github.com/garrytan/gstack) 的设计。

## 功能

- **本地化规则** — 面向非英语用户的翻译规则集（已包含 zh-TW，欢迎贡献更多语言）
- **ECC 自动更新** — Session 启动时 lazy check（不是 cron），交互式升级提示
- **全局默认值** — 预配置的 `CLAUDE.md`，包含语言偏好及 ECC/gstack 集成
- **一键安装** — 一个脚本搞定所有配置

## 快速安装

```bash
git clone --recursive https://github.com/frankekn/claude-forge.git
cd claude-forge
./install.sh
```

如果忘了 `--recursive`：

```bash
git submodule update --init
```

## 包含什么

```
claude-forge/
├── install.sh              # 一键安装
├── CLAUDE.md.template      # 全局指令模板
├── rules/zh/               # 中文规则翻译
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
│   ├── ecc-update-check.sh # 版本检查（session 启动时）
│   ├── ecc-update-hook.js  # SessionStart hook
│   └── ecc-upgrade.sh      # 升级脚本
├── settings.json.template  # Hook 配置参考
└── ecc/                    # ECC（git submodule）
```

## 自动更新机制

每次打开新的 Claude Code session 时自动检查 ECC 是否有新版本：

- **缓存 60 分钟** — 不会每次都去 GitHub fetch
- **交互式提示** — 使用 `AskUserQuestion` 提供 4 个选项：
  - 立即升级
  - 自动升级
  - 稍后提醒（snooze）
  - 不再询问
- **递增静默** — 24 小时 → 48 小时 → 7 天
- **安全升级** — `git pull --ff-only`，有冲突不会强制覆盖
- **不影响自定义** — 你的 rules、settings 在 ECC 目录外，不受影响

自动更新机制设计灵感来自 [gstack](https://github.com/garrytan/gstack) 的 `gstack-update-check`。

### 手动操作

```bash
# 强制检查一次
bash ~/.claude/scripts/ecc-update-check.sh --force

# 手动升级
bash ~/.claude/scripts/ecc-upgrade.sh

# 停用/启用更新检查
touch ~/.claude/.ecc-state/update-disabled    # 停用
rm ~/.claude/.ecc-state/update-disabled       # 启用
```

## 更新此配置包

```bash
cd claude-forge
git pull
git submodule update --remote
./install.sh
```

## 前置要求

- [Node.js](https://nodejs.org/) (v18+)
- [Git](https://git-scm.com/)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)

## 致谢

本项目建立在以下优秀开源项目之上：

- **[Everything Claude Code (ECC)](https://github.com/affaan-m/everything-claude-code)** by [Affaan M](https://github.com/affaan-m) — 驱动整个配置的核心框架，提供完整的 rules、agents、hooks、skills 和 commands 管理系统。

- **[gstack](https://github.com/garrytan/gstack)** by [Garry Tan](https://github.com/garrytan) — 本项目的自动更新机制（lazy check、缓存 TTL、递增静默、交互式升级提示）直接参考了 gstack 的 `gstack-update-check` 设计。

## 许可证

MIT
