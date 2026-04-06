# Ten Development Rules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Docs](https://img.shields.io/badge/Docs-English%20%26%20%E4%B8%AD%E6%96%87-blue.svg)](./README.md)
[![Version](https://img.shields.io/badge/version-2.5.1-blue.svg)](./SKILL.md)

[English](./README.md) | 简体中文

> **AI 写代码快，这个 Skill 让它写得*对*。**

`ten-dev-rules` 是 [Claude Code](https://claude.ai/claude-code) 的智能体技能，把 10 条工程规则变成**主动决策门控**——AI 必须先收边界再编码、先冻结契约再构建、先验证再交付。不是仪式，是纪律。

## 为什么需要它

AI 编程助手能力强但缺纪律。没有约束时，它们会：

- 不理解范围就开始写代码
- 不冻结接口就修改共享契约
- 跳过失败路径设计，只写快乐路径
- 在不同项目中重复犯同样的错误

`ten-dev-rules` 让 AI **在自身上执行工程纪律**，并**从你的错误中学习**跨项目经验。

## 8 个命令

| 命令 | 类型 | 做什么 |
|------|------|--------|
| `/10dev` | 入口 | 引导设置、项目扫描、状态仪表盘 |
| `/10plan` | 模式 | 收边界 -> 冻契约 -> 排依赖 -> 分阶段 -> WATCH LIST 预警 |
| `/10exec` | 模式 | 检测环境 -> 实现 -> 跑测试/lint -> 阶段代码审查 -> 原子提交 |
| `/10review` | 模式 | 10 规则审计 + 自检门 + 深度代码审查 -> SHIP / BLOCK |
| `/10distill` | 模式 | 提炼原则 -> 更新开发者画像 -> 跨项目模式检测 |
| `/10docs` | 模式 | 自动修复过期文档 -> 删重复 -> 生成目录 -> 归档 -> 同步 vault |
| `/10profile` | 工具 | 查看/管理开发者盲区、偏好和进步轨迹 |

所有模式也支持自然语言触发："规划这个功能"、"审查这个 PR"、"我们学到了什么"等。

**第一次用？输入 `/10dev`** — 它会引导你完成设置并启动第一个模式。

## 十条规则

| # | 规则 | 智能体行为 |
|---|------|-----------|
| 1 | **设定边界** | 定义 solves/defers/removed。Hook 标记超范围编辑。 |
| 2 | **冻结契约** | 消费方构建前必须稳定接口。写入 `.10dev/contract.md`。 |
| 3 | **按依赖排序** | 先建基础，再建消费方。循环依赖必须打破。 |
| 4 | **分阶段交付** | 拆分为有进入/退出条件和预测文件列表的阶段。 |
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

# 注册斜杠命令
cd ~/.claude/skills
for cmd in 10dev 10plan 10exec 10review 10distill 10docs 10profile; do
  ln -sf ten-dev-rules/skills/$cmd $cmd
done

# 完成。输入 /10dev 开始使用。
```

### 试一下

```
你:     /10dev
智能体: [检测新项目，扫描环境，提供 CLAUDE.md 路由设置]
        -> 环境就绪。你想先做什么？

你:     /10plan 给应用加 OAuth 登录
智能体: [收边界、冻结契约、排依赖、分阶段、展示 WATCH LIST]
        -> 结构化计划：4 个阶段，冻结的契约，失败路径，画像预警

你:     /10exec
智能体: [检测测试框架，实现每个阶段，跑测试+lint，自动审查代码]
        -> Stage 1 完成。测试: 6/6。阶段审查: R5 PASS, R7 PASS, R9 PASS。继续。

你:     /10review
智能体: [10 规则审计 + 自检门 + 逐文件深度代码审查]
        -> SHIP_WITH_CONCERNS: [P2] check-boundary.sh:42 — macOS 上 realpath 不可用

你:     /10distill
智能体: [提取模式，对比开发者画像]
        -> 2 条原则提炼。画像更新："跳过失败路径" 频次 2->3。

你:     /10profile
智能体: -> 跟踪 3 个盲区（1 HIGH, 2 MEDIUM）。已治愈："假设平台行为"。

你:     /10docs
智能体: [扫描所有文档，修复漂移，构建清理方案]
        -> UPDATED: 修复 2 个断链，创建 1 个缺失文档。DELETE 3, TOC 2, ARCHIVE 1。执行？[Y/n]
```

## 开发者画像：三层学习系统

10devrules 从你的错误中学习，跨项目。

```text
L0: 项目经验 (lessons.md)          -> 这个项目学到了什么
L1: 开发者盲区 (developer-profile) -> 跨项目反复出现的模式
L2: 通用原则 (universal-principles) -> 抽象的、与项目无关的
```

画像存储在 `~/.10dev/developer-profile.md`（全局）。运行 `/10plan` 时读取画像并生成 **WATCH LIST** — 基于已知盲区的主动预警。运行 `/10distill` 时对比新经验并提议更新。

特性：
- **关键词匹配** + agent 判断兜底
- **安全写入协议**（原子 mv + .bak 备份）支持并行会话
- **盲区治愈** — 6 个月未触发自动提议降级
- **Distill diff** — 每次 /10distill 后展示画像变化
- **画像导出** — 匿名化 markdown 可分享

## v2.5 新特性

**v2.5.1: Bug 修复。** macOS 上边界守卫 `..` 遍历绕过漏洞修复（可移植规范化）。`/10docs` 在有 `src/`/`app/` 的项目上崩溃修复。boundary violation 误报和模板占位符误报断链修复。

**v2.5.0: 自动化文档治理 (/10docs)**。完全重写为单命令管道：SCAN → UPDATE → ORGANIZE → EXECUTE → VERIFY。UPDATE 阶段在清理之前自动修复断链、补充未文档化目录、更新过期引用。结构性变更（删重复、生成目录、归档、拆分）一次确认全部执行。

**文档漂移检测**。新脚本 `bin/doc-drift-check.sh` 检测断链、未文档化的源码目录、CLAUDE.md 过期路径引用、README 版本漂移、缺失的标准文档、以及代码改了但文档没跟上的情况。

**权威源规则 (SOOT)**。新脚本 `bin/doc-soot-check.sh` 检测跨 markdown 文件的重复定义，按权威层级给出去重建议。

**自动目录生成**。超过 200 行的文件自动生成 `## 目录`（Table of Contents），AI 通过目录定位章节行号精准读取。

**AI 友好度评分**。`/10docs audit` 输出 0-5 分：CLAUDE.md 大小、重复率、目录覆盖、归档泄漏、上下文充分度。

### v2.4 要点

/10review 真实代码审查（自检门 + 深度审查）。/10exec 环境感知执行（自动检测测试框架）。阶段级代码审查。共享工具（`detect-root.sh`、`detect-env.sh`）。边界守卫增强。

## Agent 行为规则

10devrules 对 AI agent 强制执行 8 条行为规则，所有模式生效：

1. 行动前先思考 — 写代码前先阅读现有文件
2. 输出简洁，推理彻底
3. 优先编辑而不是重写整个文件
4. 不重复阅读已在上下文中的文件
5. 宣布完成前先测试
6. 不要有奉承的开场白或结束语
7. 保持解决方案简单直接
8. 用户指令始终覆盖 skill 指令

这些规则在 `/10dev` 设置时注入项目 CLAUDE.md，在每个会话中生效 — 即使不在 10dev 模式下。

## 架构

v2.5 采用**路由层架构** + 三层学习系统 + 真实代码审查 + 环境感知执行 + 自动化文档治理。

```text
SKILL.md (路由)            docs/ (模式逻辑)           skills/ (斜杠命令)
+-----------------+       +--------------------+       +--------------------+
| 规则表          |       | 10plan.md          |       | 10dev/   (入口)    |
| 模式路由        |------>| 10exec.md          |       | 10plan/  10exec/   |
| 输出模板        |       | 10review.md        |       | 10review/ 10distill|
| 反模式信号      |       | 10distill.md       |       | 10docs/ 10profile/ |
| 状态文件        |       | 10docs.md          |       +--------------------+
| 工具命令        |       | 10dev.md           |       bin/ (共享脚本)
+-----------------+       | state-files.md     |       +--------------------+
                          +--------------------+       | check-boundary.sh  |
                                                       | doc-health-audit.sh|
                                                       | doc-drift-check.sh |
                                                       | doc-toc-gen.sh     |
                                                       | doc-soot-check.sh  |
                                                       | doc-sync.sh        |
                                                       +--------------------+

全局状态 (~/.10dev/):
  developer-profile.md    L1 盲区 + 偏好
  universal-principles.md L2 抽象原则
  projects.txt            项目注册表
  .onboarded              引导标志
```

## DOCS 模式：自动化文档治理

`/10docs` 运行完整的文档治理管道 — 先更新过期文档，再清理结构：

| 命令 | 做什么 |
|------|--------|
| `/10docs` | **完整管道**：扫描 → 修复漂移 → 组织清理 → 执行 → 验证 |
| `/10docs audit` | 仅报告 — 展示会做什么，不修改任何文件 |
| `/10docs sync` | 带 YAML frontmatter 同步状态文件到 Obsidian vault |

管道自动执行修正（断链、缺失文档、过期引用），结构性变更（删重复、生成目录、归档、拆分）一次确认全部执行。

## Hook 系统

可选的边界守卫 Hook 强制执行 Rule 1：

- 读取 `.10dev/boundary.txt`（允许编辑的路径）
- 检查每次 `Edit` 和 `Write` 是否在范围内
- **建议模式**（`ask` 而非 `deny`）——你始终拥有决定权
- 目录安全匹配（防止 `/src` 匹配到 `/src-old`）

## 仓库结构

```text
.
+-- SKILL.md                  # 路由层 (v2.5)
+-- docs/
|   +-- 10plan.md             # PLAN 模式（7 阶段 + WATCH LIST）
|   +-- 10exec.md             # EXECUTE 模式（阶段循环 + 文件漂移检测）
|   +-- 10review.md           # REVIEW 模式（10 规则审计 + 画像匹配）
|   +-- 10distill.md          # DISTILL 模式（4 阶段 + 三层学习）
|   +-- 10docs.md             # DOCS 模式（自动化文档治理管道）
|   +-- 10dev.md              # /10dev 编排器逻辑
|   +-- state-files.md        # 状态文件标准格式
+-- skills/
|   +-- 10dev/                # /10dev 入口命令
|   +-- 10plan/ ... 10profile/  # 各模式斜杠命令包装
+-- bin/
|   +-- check-boundary.sh     # Rule 1 边界守卫
|   +-- detect-root.sh        # 项目根检测（4 级回退）
|   +-- detect-env.sh         # 测试/lint/类型工具检测
|   +-- doc-health-audit.sh   # 文档健康 + 治理指标
|   +-- doc-drift-check.sh    # 文档漂移检测
|   +-- doc-toc-gen.sh        # 目录检查与生成
|   +-- doc-soot-check.sh     # 权威源检测
|   +-- doc-sync.sh           # Obsidian vault 同步引擎
+-- CHANGELOG.md / README.md / README.zh-CN.md / CONTRIBUTING.md / SECURITY.md
```

## 适用场景

- **编码前** — 收范围、冻契约、排阶段
- **编码中** — 隔离阶段、审查循环、验证交付
- **编码后** — 对照 10 规则审计 PR、提炼原则
- **跨项目** — 开发者画像携带经验前行

## 不适用场景

- 极小的一行修复（流程成本大于改动本身）
- 纯发散式头脑风暴（松散探索才是目标）
- 已有更严格标准流程的领域

## 常见问题

**这只给 AI 用吗？**
不是。人类和 AI 都能用。AI 受益于明确工作流，人类受益于更少歧义。

**绑定语言或框架吗？**
不绑定。语言无关、工具无关。

**开发者画像是什么？**
一个全局文件（`~/.10dev/developer-profile.md`），跟踪你反复出现的编码盲区。`/10plan` 读取它主动预警，`/10distill` 更新它。完全可选——第一次运行 `/10distill` 时自动创建。

**需要什么依赖？**
只需要 `bash`、`grep`、`sed`。macOS 和 Linux 标配。

**可以按团队修改吗？**
可以。MIT 协议。保留核心规则，其他随意调整。

## 隐私

- 无遥测、无分析、无外部服务
- 不需要个人数据
- 开发者画像仅存本地（`~/.10dev/`）
- 所有示例保持通用
- 任何组织均可安全使用

## 贡献指南

见 [CONTRIBUTING.md](./CONTRIBUTING.md)。

## 安全说明

见 [SECURITY.md](./SECURITY.md)。

## 许可证

MIT License。完整条款见 [LICENSE](./LICENSE)。
