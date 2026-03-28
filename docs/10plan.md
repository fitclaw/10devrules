# PLAN Mode

Enter this mode to scope and structure work BEFORE coding. Proceeds through 6 phases with decision gates.

## Phase 1: Set the Boundary (Rule 1)

1. Read existing state: `todo.md`, recent `git log --oneline -10`, any plan files.
2. Define three things explicitly:
   - **Solves now**: what this task delivers
   - **Defers**: what is intentionally out of scope
   - **Removed**: adjacent ideas explicitly rejected
3. Write the boundary to `.10dev/boundary.txt` (one path per line for allowed edit directories).
4. **Gate**: If the scope lists more than 3 deliverables or the user says "and also":

```
This scope has N deliverables. Rule 1: tighten fuzzy boundaries before starting.

RECOMMENDATION: A — split into phases.

A) Split into phases — each deliverable becomes its own stage
B) Keep as one task — accept wider scope
C) Narrow further — pick the ONE most critical deliverable
```

## Phase 2: Freeze the Contract (Rule 2)

1. Use an **Explore sub-agent** to search the codebase for existing types, interfaces, API routes, database schemas, and configuration contracts that this task touches or creates.
2. Present the contract surface:
   - Types/interfaces to create or modify
   - API inputs/outputs
   - Schema changes
   - Acceptance criteria
3. **Gate**: Contracts must be confirmed stable before proceeding.

```
These are the contracts this task depends on. Rule 2: delay implementation if contracts are still moving.

A) Contracts are stable — proceed to dependency sequencing
B) Contract X needs discussion — pause and resolve first
C) Show me the existing code for these interfaces
```

## Phase 3: Sequence by Dependency (Rule 3)

1. From the contract list, determine build order. Use `Grep`/`Glob` to trace import chains.
2. Output a numbered dependency sequence (foundations -> consumers -> integration).
3. **Gate**: Circular dependencies -> ask the user to break the cycle.

## Phase 4: Stage the Work (Rule 4)

1. Generate stages from the dependency sequence. Each stage has:
   - **Name**
   - **Entry condition** (what must be true before starting)
   - **Exit condition** (what must be true to call it done)
   - **Files to touch** (predicted)
2. Write stages as checkboxes to `todo.md` under `## Stages`.

## Phase 5: Failure Path Audit (Rule 7)

1. For each stage, enumerate failure paths:
   - Timeouts, retries, rollback
   - Concurrency / race conditions
   - Auth / rate limits
   - Partial inputs, upstream failures
2. **Gate**: If any stage has zero failure paths:

```
Stage "X" has no identified failure paths. Rule 7: unhappy paths are first-class.

A) Add failure paths now — describe what can go wrong
B) This stage genuinely has no failure modes (rare — confirm?)
C) Defer to implementation — mark as tech debt
```

## Phase 6: Plan Output

Produce the structured plan using the output template defined in SKILL.md.
