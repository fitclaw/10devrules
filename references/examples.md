# Examples

Use this file when you want example prompts or lightweight response scaffolds for `ten-development-rules`.

## Example Prompts

- Use `ten-development-rules` to turn this feature request into a staged implementation plan.
- Review this pull request with `ten-development-rules` and check for scope drift, contract drift, and missing failure handling.
- Restructure this migration into dependency-ordered phases using `ten-development-rules`.
- Distill the lessons from this project into reusable engineering principles with `ten-development-rules`.
- "/10 用ten-development-rules把这次重构按阶段拆解并输出边界与验证计划"
- "/10 Review this migration and design the failure paths before implementation."

## Standard `/10` Templates

1. `/10 需求梳理`
   - 任务：<一句话描述功能/改造目标>
   - 约束：<必须满足的边界、排除项>
   - 输出：Boundary / Contract / Dependency order / Stages / Failure paths / Validation

2. `/10 计划`
   - 任务：<一句话描述当前需求>
   - 依赖：<可依赖的接口/服务/数据库/配置>
   - 交付目标：<上线截止、可接受范围>
   - 输出：Boundary / Contract / Dependency order / Stages / Failure paths / Validation

3. `/10 评审`
   - 目标：<要评审的 PR / 设计 / 文档链接>
   - 关注点：scope drift, contract drift, shared core pollution, failure handling, docs freshness
   - 输出：Findings / Open questions / Priority fixes / Validation

4. `/10 重构`
   - 重构范围：<文件/模块/组件>
   - 不改变行为：是/否（说明边界）
   - 依赖关系：<先后顺序或阻塞项>
   - 输出：Boundary / Contract / Dependency order / Stages / Failure paths / Validation

5. `/10 里程碑`
   - 目标里程碑：<v1 / v1.1 / v2 目标>
   - 分段标准：<每个阶段完成标准>
   - 输出：Boundary / Contract / Dependency order / Stages / Failure paths / Validation

6. `/10 测试`
   - 目标行为：<核心功能>
   - 风险点：<超时/并发/错误处理>
   - 输出：Boundary / Contract / Dependency order / Stages / Failure paths / Validation

7. `/10 验证`
   - 变更项：<本次变更列表>
   - 已执行/未执行：<列出>
   - 输出：Findings / Open questions / Priority fixes / Validation

8. `/10 上线`
   - 上线范围：<功能模块>
   - 监控点：<错误率、延迟、重试率>
   - 回滚条件：<触发器+执行动作>
   - 输出：Boundary / Contract / Dependency order / Stages / Failure paths / Validation

9. `/10 问题定位`
   - 现象：<出现的症状>
   - 影响面：<用户群/流程/环境>
   - 输出：Boundary / Contract / Dependency order / Stages / Failure paths / Validation

10. `/10 复盘`
    - 复盘对象：<任务/版本/事故>
    - 成果：<达成度>
    - 输出：Principles / Summary formula

## Planning Output Scaffold

```text
Boundary
- What this task solves now
- What it does not solve now

Contract
- Shared types, routes, statuses, or acceptance criteria

Dependency order
- Foundation first
- Consumers after providers

Stages
- Stage 1
- Stage 2
- Stage 3

Failure paths
- Timeout
- Partial input
- Retry / rollback / race conditions

Validation
- What will be checked
- What remains risky
```

## Review Output Scaffold

```text
Findings
- Scope drift
- Contract drift
- Missing failure-path handling

Open questions
- Assumptions that still need confirmation

Summary
- Short summary of the current state

Validation
- What was reviewed directly
- What was not verified
```

## Methodology Distillation Scaffold

```text
Principle 1
- Why it matters

Principle 2
- Why it matters

Principle 3
- Why it matters

Summary formula
- Boundary-driven, contract-driven, dependency-ordered, staged, isolated, and verified
```
