# Examples

Use this file when you want example prompts or lightweight response scaffolds for `ten-development-rules`.

## Example Prompts

- Use `ten-development-rules` to turn this feature request into a staged implementation plan.
- Review this pull request with `ten-development-rules` and check for scope drift, contract drift, and missing failure handling.
- Restructure this migration into dependency-ordered phases using `ten-development-rules`.
- Distill the lessons from this project into reusable engineering principles with `ten-development-rules`.

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
