# Ten Development Rules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Docs](https://img.shields.io/badge/Docs-English%20%26%20%E4%B8%AD%E6%96%87-blue.svg)](./README.md)
[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](./SKILL.md)

[English](./README.md) | 简体中文

> **AI 写代码快，这个 Skill 让它写得*对*。**

`ten-dev-rules` 是 [Claude Code](https://claude.ai/claude-code) 的智能体技能，把 10 条工程规则变成**主动决策门控**——AI 必须先收边界再编码、先冻结契约再构建、先验证再交付。不是仪式，是纪律。

## 为什么需要它

AI 编程助手能力强但缺纪律。没有约束时，它们会：

- 不理解范围就开始写代码
- 不冻结接口就修改共享契约
- 跳过失败路径设计，只写快乐路径
- 积累过期文档，污染未来上下文

`ten-dev-rules` 让 AI **在自身上执行工程纪律**——自动的。

## 5 种模式，5 个命令

| 命令 | 模式 | 做什么 |
|------|------|--------|
| `/10plan` | **规划** | 收边界 -> 冻契约 -> 排依赖 -> 分阶段 -> 审失败路径 |
| `/10exec` | **执行** | 隔离复杂度 -> 实现 -> 审查循环 -> 验证现实 -> 记录经验 |
| `/10review` | **审查** | 对照 10 规则审计代码/PR -> SHIP / SHIP_WITH_CONCERNS / BLOCK |
| `/10distill` | **提炼** | 从完成的工作中提取可复用原则 -> 一行总结公式 |
| `/10docs` | **文档** | 审计文档健康 -> 清理过期产物 -> 同步到 Obsidian vault -> 快照决策 |

所有模式也支持自然语言触发："规划这个功能"、"审查这个 PR"、"同步文档"等。

## 十条规则

| # | 规则 | 智能体行为 |
|---|------|-----------|
| 1 | **设定边界** | 定义 solves/defers/removed。Hook 阻止超范围编辑。 |
| 2 | **冻结契约** | 消费方构建前必须稳定接口。不稳定则阻止推进。 |
| 3 | **按依赖排序** | 先建基础，再建消费方。循环依赖必须打破。 |
| 4 | **分阶段交付** | 拆分为有进入/退出条件的阶段。禁止一锅炖。 |
| 5 | **隔离新复杂度** | 新逻辑放新文件。共享核心编辑需要理由。 |
| 6 | **构建审查闭环** | 每个阶段：实现 -> 审查 -> 修复 -> 再验证。 |
| 7 | **设计失败路径** | 逐阶段枚举异常路径。零失败路径 = 硬停。 |
| 8 | **压缩文档** | 活文档，非历史。只写恢复上下文所需的最少内容。 |
| 9 | **验证现实** | 标记完成前必须说明 已验证/已跳过/剩余风险。 |
| 10 | **提炼复用原则** | 用动词提取模式：scope、freeze、isolate、verify。 |

每条规则是**门控**，不是建议。智能体在工作流特定节点强制执行。

## 快速开始

### 30 秒安装

```bash
# 克隆到 Claude Code skills 目录
git clone https://github.com/fitclaw/10devrules.git ~/.claude/skills/ten-dev-rules

# 完成。开始任何开发任务，技能自动激活。
```

或手动复制 `SKILL.md` + `docs/` + `bin/` 到你喜欢的位置。

### 试一下

```
你:     /10plan 给应用加 OAuth 登录
智能体: [收边界、发现现有接口、排依赖、分阶段、审失败路径]
        -> 结构化计划：4 个阶段，冻结的契约，逐阶段失败路径

你:     /10exec
智能体: [每个阶段：隔离 -> 实现 -> 审查 -> 验证 -> 更新]
        -> 代码交付，每阶段附验证记录

你:     /10review
智能体: [对照 10 规则审计 diff]
        -> SHIP_WITH_CONCERNS: Rule 7 token 刷新缺少超时处理

你:     /10docs
智能体: [扫描 todo.md、lessons.md、契约的过期情况]
        -> YELLOW: 3 个过期任务，2 条无标签经验。建议：运行 /10docs cleanup
```

## 架构：路由层 + 智能体集群

v2.1 采用**路由层架构**——`SKILL.md` 是轻量路由（~250行），分发到详细模式文件。智能体按需读取。

```text
SKILL.md (路由)            docs/ (模式逻辑)            bin/ (执行引擎)
┌──────────────────┐      ┌─────────────────────┐      ┌────────────────────┐
│ 规则表           │      │ 10plan.md           │      │ check-boundary.sh  │
│ 模式路由         │─────>│ 10exec.md           │      │ doc-health-audit.sh│
│ 输出模板         │      │ 10review.md         │      │ doc-sync.sh        │
│ 反模式信号       │      │ 10distill.md        │      └────────────────────┘
│ 状态文件         │      │ 10docs.md           │
└──────────────────┘      └─────────────────────┘
```

## DOCS 模式：Obsidian 集成

`/10docs` 管理文档健康和跨版本记忆，通过 Obsidian：

| 子命令 | 做什么 |
|--------|--------|
| `/10docs audit` | 检测过期任务、无标签经验、契约漂移、孤立文档 |
| `/10docs cleanup` | Phase-aware 归档：快照已完成工作，重新开始 |
| `/10docs sync` | 带 YAML frontmatter 同步状态文件到 Obsidian vault |
| `/10docs snapshot` | 创建版本化决策记录 (ADR) |
| `/10docs index` | 重建 phase-aware 阅读顺序 |

Vault 结构：
```
~/dev-vault/projects/{project}/
├── _index.md        # 自动生成阅读顺序
├── active/          # 当前阶段文档（带 frontmatter）
├── archive/         # 已完成阶段快照
├── decisions/       # 版本化 ADR
└── lessons/         # 按主题组织
```

## Hook 系统

可选的边界守卫 Hook 强制执行 Rule 1：

- 读取 `.10dev/boundary.txt`（允许编辑的路径）
- 检查每次 `Edit` 和 `Write` 是否在范围内
- **建议模式**（`ask` 而非 `deny`）——你始终拥有决定权
- 无 boundary 文件 = 允许所有编辑

```bash
mkdir -p .10dev
echo "src/features/auth" > .10dev/boundary.txt
```

## 仓库结构

```text
.
├── SKILL.md                  # 路由层
├── docs/
│   ├── 10plan.md             # PLAN 模式逻辑
│   ├── 10exec.md             # EXECUTE 模式逻辑
│   ├── 10review.md           # REVIEW 模式逻辑
│   ├── 10distill.md          # DISTILL 模式逻辑
│   └── 10docs.md             # DOCS 模式（Obsidian 同步）
├── bin/
│   ├── check-boundary.sh     # Rule 1 边界守卫
│   ├── doc-health-audit.sh   # 文档健康检查
│   └── doc-sync.sh           # Obsidian vault 同步引擎
├── README.md
├── README.zh-CN.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

## 适用场景

- **编码前** — 收范围、冻契约、排阶段
- **编码中** — 隔离阶段、审查循环、验证交付
- **编码后** — 对照 10 规则审计 PR、提炼原则
- **持续** — 保持文档健康、同步决策到 Obsidian

## 不适用场景

- 极小的一行修复（流程成本大于改动本身）
- 纯发散式头脑风暴（松散探索才是目标）
- 已有更严格标准流程的领域

## 常见问题

**这只给 AI 用吗？**
不是。人类和 AI 都能用。AI 受益于明确工作流，人类受益于更少歧义。

**绑定语言或框架吗？**
不绑定。语言无关、工具无关。

**可以不用 Hook 吗？**
可以。Hook 是可选的。所有规则仅通过 `SKILL.md` 即可工作。

**需要什么依赖？**
只需要 `bash`、`grep`、`sed`。macOS 和 Linux 标配。不需要 npm、pip、Docker。

**可以按团队修改吗？**
可以。MIT 协议。保留核心规则，其他随意调整。

## 隐私

- 无遥测、无分析、无外部服务
- 不需要个人数据
- 所有示例保持通用
- 任何组织均可安全使用

## 贡献指南

见 [CONTRIBUTING.md](./CONTRIBUTING.md)。

## 安全说明

见 [SECURITY.md](./SECURITY.md)。

## 许可证

MIT License。完整条款见 [LICENSE](./LICENSE)。
