---
name: ten-development-rules
description: Boundary-first, contract-first workflow for planning, restructuring, reviewing, or executing software development tasks. Use when Codex needs to define in-scope vs out-of-scope work, freeze types or interfaces before implementation, sequence work by dependency, isolate new domain logic from shared core, add review and validation loops, or distill concrete project work into reusable engineering principles.
---

# Ten Development Rules

## Usage Compatibility

If you came from the `/10` series, use the same style to keep UX consistent:
- `/10 ...`  (preferred for backward compatibility)
- `$ten-development-rules ...` (explicit skill call)
- `Use ten-development-rules ...` (natural language)

They all map to this skill. Keep the task intent in one sentence after the prefix.

## Standard /10 Output Contract

- Planning / restructuring / implementation mode: `Boundary`, `Contract`, `Dependency order`, `Stages`, `Failure paths`, `Validation`
- Review mode: `Findings`, `Open questions`, `Priority fixes`, `Validation`
- Distillation mode: `Principles`, `Summary formula`

Use this skill when the work needs structure before execution: planning, restructuring, review, staged delivery, or turning project work into reusable engineering principles.

## Default Stance

- Start from scope, not solution shape.
- Prefer explicit contracts over implicit assumptions.
- Build from lower dependencies upward.
- Keep new complexity local until repeated pressure justifies abstraction.
- Treat review, failure handling, and verification as part of delivery.

## Core Workflow

1. Set the boundary.
   - State what the task solves now and what it does not solve now.
   - Remove adjacent ideas unless they block the current task.

2. Freeze the contract.
   - Define the types, routes, statuses, inputs, outputs, ownership, or acceptance criteria that other work depends on.
   - Keep shared contracts in one obvious place.

3. Sequence by dependency.
   - Build providers before consumers.
   - Parallelize only when contracts are stable and file ownership does not overlap.

4. Stage the work.
   - Split the task into phases with explicit outputs and entry or exit conditions.
   - Prefer several small stage boundaries over one oversized implementation pass.

5. Isolate new complexity.
   - Keep new domain logic in domain-specific files, modules, tables, or services.
   - Protect shared core from speculative reuse.

6. Build the review loop.
   - Treat implementation, review, fixes, and re-verification as one loop.
   - Define how the change will be checked before calling it done.

7. Design failure paths.
   - Check timeouts, retries, rollback, idempotency, concurrency, auth, rate limits, and cost controls.
   - Treat unhappy paths as first-class behavior.

8. Compress documentation.
   - Write only the docs needed to restore current truth quickly.
   - Make the default reading order explicit when the repo contains legacy narratives.

9. Verify reality.
   - Prefer checks that reveal real runtime behavior.
   - Call out what was verified, what was skipped, and what still carries risk.

10. Distill reusable principles.
    - Lift patterns out of feature names when summarizing work.
    - End with a short formula the team can reuse.

## Response Shapes

- For planning, return: Boundary, Contract, Dependency order, Stages, Failure paths, Validation.
- For review, check scope drift, contract drift, shared-core pollution, missing unhappy-path handling, misleading tests, and stale docs first.
- For methodology distillation, extract short principles with why they matter and end with a reusable one-line summary.

## Load References As Needed

- Read [references/workflow.md](./references/workflow.md) for expanded guidance on sequencing, staging, failure handling, and verification.
- Read [references/review-checklist.md](./references/review-checklist.md) for review heuristics and common failure modes.
- Read [references/examples.md](./references/examples.md) for example prompts and output scaffolds.

## Anti-Patterns

- Do not design the full future system when the current task has a narrower boundary.
- Do not let consumers define contracts that providers have not stabilized.
- Do not abstract early just because two things sound similar.
- Do not treat review or smoke checks as ceremonial.
- Do not write documentation that preserves history but hides current truth.

## Default Summary Formula

Describe the approach as boundary-driven, contract-driven, dependency-ordered, staged, isolated, and closed-loop verified.
