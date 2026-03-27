# Ten Development Rules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Docs](https://img.shields.io/badge/Docs-English%20%26%20%E4%B8%AD%E6%96%87-blue.svg)](./README.md)
[![Maintained](https://img.shields.io/badge/Maintained-yes-success.svg)](./README.zh-CN.md)

[English](./README.md) | 简体中文

一个**智能体驱动**的开发工作流，将 10 条规则作为主动决策门控——不只是参考清单。

`ten-dev-rules` 是面向 Claude Code 及兼容 AI Harness 的 `SKILL.md` 智能体技能。它通过四种运行模式主动编排开发工作：**PLAN**（规划）、**EXECUTE**（执行）、**REVIEW**（审查）、**DISTILL**（提炼）。

## v2.0 变更

v1.x 是一份被动参考文档。v2.0 将其改造为**主动智能体**：

- **四种运行模式**，各有独立工作流和结构化输出
- **决策门控**——智能体主动执行规则，而非仅仅建议
- **Hook 强制执行**——可选的 `bin/check-boundary.sh` 阻止超出边界的编辑（Rule 1）
- **子代理委派**——使用 Explore 代理进行契约发现和依赖分析
- **状态文件**——`.10dev/boundary.txt`、`todo.md`、`lessons.md` 实现跨会话记忆
- **结构化输出**——审计报告、阶段完成记录、提炼原则

## 目录

- [十条规则](#十条规则)
- [四种运行模式](#四种运行模式)
- [快速开始](#快速开始)
- [Hook 系统](#hook-系统)
- [仓库结构](#仓库结构)
- [示例提示词](#示例提示词)
- [适用场景](#适用场景)
- [不适用场景](#不适用场景)
- [隐私与开源发布](#隐私与开源发布)
- [常见问题](#常见问题)
- [贡献指南](#贡献指南)
- [安全说明](#安全说明)
- [许可证](#许可证)

## 十条规则

每条规则都是工作流中特定节点的**决策门控**：

| # | 规则 | 智能体行为 |
|---|------|-----------|
| 1 | **设定边界** | 实现前必须确定范围。Hook 阻止超范围编辑。 |
| 2 | **冻结契约** | 消费方构建前必须稳定接口。 |
| 3 | **按依赖排序** | 必须先构建基础，再构建消费方。 |
| 4 | **分阶段交付** | 必须拆分为有进入/退出条件的阶段。 |
| 5 | **隔离新复杂度** | 新逻辑放新文件。共享核心编辑需要理由。 |
| 6 | **构建审查闭环** | 每个阶段：实现 → 审查 → 修复 → 再验证。 |
| 7 | **设计失败路径** | 必须逐阶段枚举异常路径。 |
| 8 | **压缩文档** | 只写恢复上下文所需的最少文档。活文档，非历史。 |
| 9 | **验证现实** | 标记完成前必须说明 已验证/已跳过/剩余风险。 |
| 10 | **提炼复用原则** | 用动词提取模式：scope、freeze、sequence、stage、isolate、review、verify。 |

## 四种运行模式

### PLAN 模式

编码**之前**确定范围和结构。六个阶段带决策门控：

1. **设定边界** (R1) → 明确 solves / defers / removed
2. **冻结契约** (R2) → 子代理探索代码库发现接口
3. **依赖排序** (R3) → 构建顺序分析
4. **分阶段** (R4) → 带进入/退出条件的阶段
5. **失败路径审计** (R7) → 逐阶段枚举异常路径
6. **输出** → 结构化计划文档

### EXECUTE 模式

带验证循环的阶段式实现：

```
对每个阶段：
  1. 隔离 (R5) — 新复杂度放新文件
  2. 实现 — 编码
  3. 审查循环 (R6) — 自审 + 测试
  4. 验证 (R9) — 已验证/已跳过/风险 报告
  5. 更新 — 标记完成 + 记录经验
```

包含自我修正：同一问题 3 次修复失败则升级询问用户。

### REVIEW 模式

对照全部 10 条规则审计现有代码或 PR：

```
Rule 1  - 边界:      PASS | DRIFT | VIOLATION
Rule 2  - 契约:      PASS | UNSTABLE | VIOLATION
...
Rule 10 - 提炼:      PASS | SKIPPED | N/A
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
结论: SHIP | SHIP_WITH_CONCERNS | BLOCK
```

### DISTILL 模式

从完成的工作中提取可复用原则 → 一行总结公式。

## 快速开始

### 方式一：作为 Claude Code Skill

1. 将 `SKILL.md` 和 `bin/` 复制到你的 Claude Code skills 目录。
2. 开始开发任务时智能体自动激活。
3. 说"规划这个功能"或"审查这个 PR"触发特定模式。

### 方式二：作为仓库级规范

1. 将 `SKILL.md` 放在项目根目录。
2. 在 `CLAUDE.md` 或 AI 指令中引用它。
3. 10 条规则作为你的开发方法论。

### 方式三：不使用 Hook（轻量版）

只使用 `SKILL.md`，不需要 `bin/` 目录。所有规则作为智能体指令工作——Hook 是可选的强制执行层。

## Hook 系统

可选的 `bin/check-boundary.sh` 脚本强制执行 Rule 1（设定边界）：

- 读取 `.10dev/boundary.txt`（允许编辑的路径，每行一个）
- 检查每次 `Edit` 和 `Write` 操作是否在边界内
- **建议模式**（`ask` 而非 `deny`）——用户始终拥有最终决定权
- 无 boundary 文件 → 允许所有编辑

手动设置边界：

```bash
mkdir -p .10dev
echo "src/features/auth" > .10dev/boundary.txt
```

## 仓库结构

```text
.
├── SKILL.md              # 智能体技能（核心）
├── bin/
│   └── check-boundary.sh # 可选 Hook，Rule 1 边界守卫
├── README.md
├── README.zh-CN.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
└── LICENSE
```

## 示例提示词

- "用 ten-dev-rules 规划这个功能" → 触发 PLAN 模式
- "用 10 条规则审查这个 PR" → 触发 REVIEW 模式
- "执行计划的第 2 阶段" → 触发 EXECUTE 模式
- "这个项目我们学到了什么？" → 触发 DISTILL 模式
- "先收紧边界再开始写代码" → 触发 PLAN Phase 1

## 适用场景

- 编码前规划功能
- 将大任务拆分为分阶段交付
- 审查代码中的隐藏风险、漂移或缺失验证
- 重构时保护共享契约
- 提炼可复用的工程原则

## 不适用场景

- 极小的改动，使用完整流程成本大于收益
- 目标就是发散式头脑风暴
- 已有更严格的标准流程的领域

## 隐私与开源发布

- 不需要真实姓名、邮箱或组织标识
- 不需要遥测、分析或外部服务
- 不引用内部数据、工单编号或私有 URL
- 所有示例保持通用

## 常见问题

### 这只给 AI 用吗？

不是。人类和 AI 都能用。AI 受益于明确的工作流，人类受益于更少的歧义。

### 绑定特定语言或框架吗？

不绑定。语言无关、工具无关。

### Hook 脚本需要什么依赖？

只需要 `bash`、`grep`、`sed`，以及可选的 `python3`（作为 JSON 解析后备）。macOS 和 Linux 标配。

### 可以不用 Hook 吗？

可以。Hook 是可选的。所有 10 条规则仅通过 `SKILL.md` 中的智能体指令即可工作。

### 可以按团队情况修改吗？

可以。保留核心规则，调整示例、术语或检查项即可。

## 贡献指南

见 [CONTRIBUTING.md](./CONTRIBUTING.md)。

## 安全说明

见 [SECURITY.md](./SECURITY.md)。

## 许可证

MIT License。完整条款见 [LICENSE](./LICENSE)。
