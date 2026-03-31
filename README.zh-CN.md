# Ten Development Rules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Docs](https://img.shields.io/badge/Docs-English%20%26%20%E4%B8%AD%E6%96%87-blue.svg)](./README.md)
[![Maintained](https://img.shields.io/badge/Maintained-yes-success.svg)](./README.zh-CN.md)

[English](./README.md) | 简体中文

一个面向软件开发团队与 AI 编码代理的通用工作方法 skill。

`ten-development-rules` 现在按 Codex 可直接消费的 skill 仓库来组织，核心目标是帮助使用者先收紧边界、先冻结契约、按依赖顺序推进实现、把新增复杂度局部化，并把评审与验证纳入交付闭环。

## 目录

- [为什么需要这个 Skill](#为什么需要这个-skill)
- [适用对象](#适用对象)
- [它解决什么问题](#它解决什么问题)
- [适用场景](#适用场景)
- [不适用场景](#不适用场景)
- [Codex 安装方式](#codex-安装方式)
- [快速开始](#快速开始)
- [Codex Skill 结构](#codex-skill-结构)
- [示例提示词](#示例提示词)
- [仓库结构](#仓库结构)
- [隐私与开源发布](#隐私与开源发布)
- [常见问题](#常见问题)
- [贡献指南](#贡献指南)
- [安全说明](#安全说明)
- [许可证](#许可证)

## 为什么需要这个 Skill

很多软件任务失败，并不是因为代码不会写，而是因为在编码之前就已经出现了问题：

- 范围没有收紧，任务不断外溢
- 上层依赖建立在还没稳定的契约之上
- 共享核心被过早抽象污染
- 评审、失败路径和验证被放到最后补做

这个 skill 提供了一套轻量但稳定的默认工作方式，帮助你在真正编码之前先把这些风险降下来。

## 适用对象

- 支持 `SKILL.md` 或仓库级 AI 指令的编码代理
- 需要做需求规划、重构、评审、实施的工程师
- 希望建立统一工程习惯、但不想引入重型流程的团队

## 它解决什么问题

这个 skill 总结为十条规则：

1. 先设定边界。
2. 先冻结契约。
3. 按依赖顺序推进。
4. 分阶段交付。
5. 把新复杂度隔离起来。
6. 把评审做成闭环。
7. 把失败路径当成一等公民。
8. 压缩文档，只保留恢复上下文所需的最小信息。
9. 验证真实行为，而不是验证想象中的行为。
10. 从具体项目中提炼可复用原则。

## 适用场景

- 在编码前把一个模糊需求整理成执行计划
- 把大任务拆成契约、基础层、服务层、路由层、UI 层等阶段
- 评审现有实现时检查范围漂移、契约漂移、失败路径缺失
- 重构共享系统时避免把临时复杂度扩散到全局
- 在项目结束后沉淀可复用的方法论

## 不适用场景

- 极小的改动，使用完整流程反而增加成本
- 目标就是发散式头脑风暴，而不是收敛执行
- 某些领域已经有更严格、不可替代的标准流程

## Codex 安装方式

如果你想把这个仓库直接作为本地 Codex skill 使用，可以把它放到 `~/.codex/skills/ten-development-rules`：

```bash
mkdir -p ~/.codex/skills
git clone https://github.com/fitclaw/10devrules.git ~/.codex/skills/ten-development-rules
```

如果仓库已经克隆在别处，也可以通过复制或软链接的方式放到这个目录。

## 快速开始

### 方式一：作为独立 Skill 使用

1. 保留仓库中的 `SKILL.md`。
2. 在支持 markdown 指令的 AI 工作流中加载它。
3. 在规划、评审、重构、实施时显式调用 `ten-development-rules`。
4. 只有在需要更详细的工作流说明、评审清单或示例时，再读取 `references/`。

### 方式二：作为仓库级规范使用

1. 把 `SKILL.md` 作为方法论源文件保留。
2. 将其中适合你的部分引用到仓库级 AI 指令中。
3. 保持核心规则不变，只调整示例、术语或领域化补充。

## Codex Skill 结构

这个仓库按渐进式加载来组织：

- `SKILL.md` 放触发描述和最核心的工作规则，供 Codex 优先加载。
- `agents/openai.yaml` 放技能展示元数据和默认提示词。
- `references/` 放更详细的工作流说明、评审启发式清单和示例，按需读取。
- `README.md` 与 `README.zh-CN.md` 主要服务于人类读者，而不是核心 skill 上下文。

## 示例提示词

- “使用 ten-development-rules 把这个需求整理成分阶段执行方案。”
- “用 ten-development-rules 评审这次改动，重点检查范围漂移、契约漂移和缺失的失败路径。”
- “把这个重构任务按依赖顺序拆开，避免共享核心被污染。”
- “把这次项目经验提炼成可复用原则，不要只复述功能细节。”

## 仓库结构

```text
.
├── agents/
│   └── openai.yaml
├── references/
│   ├── examples.md
│   ├── review-checklist.md
│   └── workflow.md
├── SKILL.md
├── README.md
├── README.zh-CN.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── LICENSE
└── .github/
```

## 隐私与开源发布

这套文档默认按“可公开发布”来写：

- 不依赖真实姓名、邮箱、公司名或个人主页
- 不引用内部地址、工单编号、客户信息或私有系统
- 不要求任何外部服务或遥测
- 所有公开示例都保持抽象与通用

如果你未来要做企业内部版，建议把内部案例、组织流程、系统名、私有约束放到私有仓库，而不是混在这个公开仓库里。

## 常见问题

### 这只是给 AI 用的吗？

不是。它既适用于 AI，也适用于人类团队。AI 会受益于明确结构，人类会受益于更少的歧义。

### 它绑定某种语言或框架吗？

不绑定。它是通用的软件开发方法论，不依赖某个技术栈。

### 它算完整项目管理方法吗？

不算重型框架。它更像一套紧凑的执行与评审启发式规则。

### 我可以按团队情况修改吗？

可以。建议保留十条核心规则，把示例、术语、检查项按团队语境扩展。

## 贡献指南

见 [CONTRIBUTING.md](./CONTRIBUTING.md)。

## 安全说明

见 [SECURITY.md](./SECURITY.md)。

## 许可证

本项目使用 MIT License。简单来说，这意味着你可以使用、复制、修改、合并、发布、分发、再许可，甚至销售本项目的副本。

主要条件也很简单：

- 保留原始版权声明
- 在项目的重要副本中保留许可证文本
- 理解本项目按 “as is” 提供，不附带任何担保

除非另有说明，提交到本仓库的贡献默认也按同一 MIT License 提供。

完整条款见 [LICENSE](./LICENSE)。
