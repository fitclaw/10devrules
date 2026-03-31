# Workflow Guide

Use this file when the base `SKILL.md` is not enough and the task needs more detailed execution guidance.

## Default Stance

- Start from scope, not solution shape.
- Prefer explicit contracts over implicit assumptions.
- Build from lower dependencies upward.
- Keep new complexity local until repeated pressure justifies abstraction.
- Treat review, failure handling, and verification as part of delivery.

## Expanded Workflow

### 1. Set the Boundary

- State what the task solves now.
- State what it does not solve now.
- Remove adjacent ideas unless they are blocking work for the current task.
- Tighten the scope before implementation if the boundary is fuzzy.

### 2. Freeze the Contract

- Define the types, statuses, routes, inputs, outputs, ownership, or acceptance criteria that downstream work will depend on.
- Keep shared contracts in one obvious place.
- Delay broad implementation if the contract is still moving.

### 3. Sequence by Dependency

- Build shared foundations before consumers.
- Let upper layers consume stable lower-layer behavior instead of inventing it.
- Parallelize only when contracts are stable and ownership boundaries are clear.

### 4. Stage the Work

Split large tasks into phases with explicit outputs. Typical stage labels:

- Contract
- Schema
- Service
- Route
- UI
- Review
- Verification

Prefer several small stage boundaries over one oversized feature pass.

### 5. Isolate New Complexity

- Put new domain logic in domain-specific files, modules, tables, or services.
- Protect shared core from speculative reuse.
- Abstract only after repeated pressure, not in anticipation.

### 6. Build the Review Loop

- Plan implementation, review, fix, and re-verification as one delivery loop.
- Define what evidence will count as done before implementation starts.
- Update source-of-truth docs when the meaning of the system changes.

### 7. Design Failure Paths

Review these risks explicitly:

- Timeouts
- Retries
- Rollback
- Idempotency
- Concurrency
- Auth
- Rate limits
- Cost controls

Also ask what happens when upstreams fail, inputs are partial, or operations race.

### 8. Compress Documentation

- Write the minimum documentation that restores context quickly.
- Separate living specs from historical material.
- Make the default reading order explicit when legacy narratives still exist.

### 9. Verify Reality

- Prefer checks that reveal real runtime behavior.
- Keep smoke tests honest.
- Do not count expected failures as success.
- State what was verified, what was skipped, and what still carries risk.

### 10. Distill Reusable Principles

- Lift patterns out of feature names when summarizing work.
- Prefer verbs such as scope, freeze, sequence, stage, isolate, review, and verify.
- End with a short formula the team can reuse later.

## Validation Prompts

Use these prompts when deciding whether a change is actually done:

- What did we verify directly?
- What did we skip?
- What still carries risk?
- Which contract became the source of truth?
- Which new complexity stayed local, and what would justify extracting it later?
