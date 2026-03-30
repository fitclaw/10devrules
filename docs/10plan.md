# PLAN Mode

Enter this mode to scope and structure work BEFORE coding. Proceeds through 7 phases with decision gates.

## Phase 0: Developer Profile Check

1. Check for developer profile: `[ -f ~/.10dev/developer-profile.md ]`
2. If file exists, read it into context.
3. Also check for universal principles: `[ -f ~/.10dev/universal-principles.md ]` — if exists, read it.
4. Register this project in the global registry:

```bash
mkdir -p ~/.10dev
_PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
grep -qxF "$_PROJECT_ROOT" ~/.10dev/projects.txt 2>/dev/null || echo "$_PROJECT_ROOT" >> ~/.10dev/projects.txt
```

5. **New project detection**: If this project path was just added to `projects.txt` (not previously present) AND the profile has blind spots, generate a **welcome message**:

```
Welcome to a new project. Based on your developer profile:

Your top blind spots for this type of work:
⚠ HIGH: {pattern_name} — {defense}
  MEDIUM: {pattern_name} — {defense}

I'll include these in the plan's WATCH LIST.
```

6. If no profile exists, proceed silently to Phase 1.

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
3. Write the frozen contracts to `.10dev/contract.md`:

```markdown
# Frozen Contracts — {task name}

## Types/Interfaces
{list each type/interface with signature}

## API Surface
{endpoints, inputs, outputs}

## Schema
{database or config schema changes}

## Acceptance Criteria
{what must be true for this task to be considered done}
```

4. **Gate**: Contracts must be confirmed stable before proceeding.

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
   - **Files to touch** (predicted, comma-separated)
2. Write stages as checkboxes to `todo.md` under `## Stages`, using the canonical format:

```
- [ ] Stage N: {name} | Entry: {cond} | Exit: {cond} | Files: {path1, path2}
```

The `Files:` field is required. EXECUTE uses it to detect file drift (edits outside predicted files).

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

## Phase 6: WATCH LIST (Developer Profile Gate)

If a developer profile was loaded in Phase 0:

1. For each blind spot in the profile, check its `Keywords` field against the task boundary (Phase 1) and contract surface (Phase 2).
2. If keyword match found, OR the trigger scenario is relevant to this task (agent judgment as fallback), include it in the WATCH LIST.
3. Insert WATCH LIST into the plan output after Boundary, before Contract:

```
## WATCH LIST (from developer profile)

⚠ HIGH: {pattern_name}
  Trigger: {trigger description}
  Defense: {defense action}
  - [ ] Acknowledged: {pattern_name}

MEDIUM: {pattern_name}
  Trigger: {trigger description}
  Defense: {defense action}
```

4. HIGH severity items add an acknowledgment checkbox. The plan is not blocked, but the unchecked item is visible.
5. LOW severity items are only included if keyword match is strong.
6. If no blind spots match the current task, skip the WATCH LIST section.

## Phase 7: Plan Output

Produce the structured plan using the output template defined in SKILL.md. The WATCH LIST (if any) is included between the Boundary and Contract sections.
