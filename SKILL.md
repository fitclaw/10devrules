---
name: ten-dev-rules
preamble-tier: 2
version: 2.0.0
description: |
  Agent-driven development workflow using 10 rules as active decision gates.
  Four modes: PLAN (boundary→contract→dependency→stages), EXECUTE (isolate→review→verify loop),
  REVIEW (10-rule audit), DISTILL (extract reusable principles).
  Use when starting any non-trivial development task, reviewing code, or extracting lessons.
  Use when asked to "plan a feature", "start a task", "review this code", "what did we learn",
  "scope this", "audit this PR", or any development work that benefits from structured scoping.
  Proactively suggest when user starts coding without scoping, skips failure path design, or
  marks work done without verification.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
  - WebSearch
hooks:
  PreToolUse:
    - matcher: "Edit"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/bin/check-boundary.sh"
          statusMessage: "Rule 1: Checking scope boundary..."
    - matcher: "Write"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/bin/check-boundary.sh"
          statusMessage: "Rule 1: Checking scope boundary..."
---

# Ten Development Rules — Agent Skill v2.0

An active development agent that uses 10 rules as decision gates, not just a reference list.

## Preamble (run first)

```bash
# Detect project state
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_HAS_BOUNDARY=$([ -f .10dev/boundary.txt ] && echo "yes" || echo "no")
_HAS_TODO=$([ -f todo.md ] && echo "yes" || echo "no")
_HAS_LESSONS=$([ -f lessons.md ] && echo "yes" || echo "no")
echo "BRANCH: $_BRANCH"
echo "BOUNDARY_SET: $_HAS_BOUNDARY"
echo "TODO_EXISTS: $_HAS_TODO"
echo "LESSONS_EXISTS: $_HAS_LESSONS"
```

If `BOUNDARY_SET` is `yes`, read `.10dev/boundary.txt` before proceeding — the scope is locked.
If `TODO_EXISTS` is `yes`, read `todo.md` to understand current task state.
If `LESSONS_EXISTS` is `yes`, scan `lessons.md` for relevant prior lessons before starting.

---

## Mode Detection

Detect the operating mode from the user's request:

| Signal | Mode |
|--------|------|
| "plan", "scope", "design", "architect", "start a task", "begin" | **PLAN** |
| "build", "implement", "execute", "code this", "do it" | **EXECUTE** |
| "review", "audit", "check", "look at this", "PR review" | **REVIEW** |
| "distill", "retro", "what did we learn", "extract patterns", "summarize" | **DISTILL** |

If ambiguous, ask:

```
What mode should I operate in?

A) PLAN — Define scope, contracts, stages, and failure paths before coding
B) EXECUTE — Implement staged work with isolation, review loops, and verification
C) REVIEW — Audit existing code/PR against the 10 rules
D) DISTILL — Extract reusable principles from completed work
```

---

## The Ten Rules

These rules are not passive advice. Each rule is a **decision gate** enforced at specific points in the workflow.

| # | Rule | Agent Behavior |
|---|------|----------------|
| 1 | **Set the boundary** | Must define solves/defers/removed BEFORE any implementation. Hook blocks out-of-scope edits. |
| 2 | **Freeze the contract** | Must stabilize interfaces before consumers are built. Gate: unstable contract blocks Phase 3. |
| 3 | **Sequence by dependency** | Must build foundations before consumers. Circular deps require user resolution. |
| 4 | **Stage the work** | Must split into phases with entry/exit conditions. No single oversized pass allowed. |
| 5 | **Isolate new complexity** | New logic goes in new files/modules. Shared core edits require explicit justification. |
| 6 | **Build the review loop** | Every stage includes implement→review→fix→re-verify as one cycle. |
| 7 | **Design failure paths** | Must enumerate unhappy paths per stage. Zero failure paths requires confirmation. |
| 8 | **Compress documentation** | Write minimum docs that restore context. Separate living specs from history. |
| 9 | **Verify reality** | Must state verified/skipped/risk before marking done. No ceremonial checks. |
| 10 | **Distill reusable principles** | Extract patterns using verbs (scope, freeze, sequence, stage, isolate, review, verify). |

---

## Default Stance

- Start from scope, not solution shape.
- Prefer explicit contracts over implicit assumptions.
- Build from lower dependencies upward.
- Keep new complexity local until repeated pressure justifies abstraction.
- Treat review, failure handling, and verification as part of delivery — not afterthoughts.

---

## PLAN Mode

Enter this mode to scope and structure work BEFORE coding. Proceeds through 6 phases with decision gates.

### Phase 1: Set the Boundary (Rule 1)

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

### Phase 2: Freeze the Contract (Rule 2)

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

### Phase 3: Sequence by Dependency (Rule 3)

1. From the contract list, determine build order. Use `Grep`/`Glob` to trace import chains.
2. Output a numbered dependency sequence (foundations → consumers → integration).
3. **Gate**: Circular dependencies → ask the user to break the cycle.

### Phase 4: Stage the Work (Rule 4)

1. Generate stages from the dependency sequence. Each stage has:
   - **Name**
   - **Entry condition** (what must be true before starting)
   - **Exit condition** (what must be true to call it done)
   - **Files to touch** (predicted)
2. Write stages as checkboxes to `todo.md` under `## Stages`.

### Phase 5: Failure Path Audit (Rule 7)

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

### Phase 6: Plan Output

Produce the structured plan:

```
10 DEV RULES: PLAN
━━━━━━━━━━━━━━━━━━
Task: [one-line description]

## Boundary (R1)
Solves: ...
Defers: ...
Removed: ...

## Contract (R2)
[frozen interfaces/types/schemas]

## Dependency Order (R3)
1. [foundation] → 2. [consumer] → 3. [integration]

## Stages (R4)
- [ ] Stage 1: [name] | Entry: [cond] | Exit: [cond]
- [ ] Stage 2: ...

## Failure Paths (R7)
[per-stage enumeration]

## Validation (R9)
[what will be verified and how]
━━━━━━━━━━━━━━━━━━
```

---

## EXECUTE Mode

Assumes a plan exists (from PLAN mode or an existing `todo.md`). Runs a stage loop.

### Stage Loop

For each unchecked stage in `todo.md`:

**1. Isolate (Rule 5)**
- Determine if this stage introduces new complexity.
- New domain logic → create new files/modules. Do NOT modify shared core unless justified.
- The `check-boundary.sh` hook reads `.10dev/boundary.txt` and flags edits outside scope.
- If shared code must change, ask first:

```
This edit touches shared code at [path]. Rule 5: isolate new complexity.

A) Proceed — this shared change is necessary and I'll explain why
B) Refactor — extract to a new file instead
C) Defer — mark as tech debt for later
```

**2. Implement**
- Write the code for this stage following the dependency sequence.
- After implementation, immediately run available tests.

**3. Review Loop (Rule 6)**
- Run `git diff` to see what changed.
- Self-review the diff against the stage's exit conditions.
- If tests exist, run them.
- If the diff touches files NOT in the stage's predicted file list, flag it.

**4. Verify (Rule 9)**
- Before marking a stage complete, state explicitly:

```
STAGE COMPLETE: [name]
━━━━━━━━━━━━━━━━━━━━━
Rule 5 (Isolate):  [new files created / shared code status]
Rule 6 (Review):   [self-review summary]
Rule 9 (Verify):
  Verified: [what was checked — tests, logs, behavior]
  Skipped:  [what was not checked and why]
  Risk:     [remaining unknowns]
━━━━━━━━━━━━━━━━━━━━━
```

**Gate**: Cannot mark a stage done without at least one verification item under "Verified".

**5. Update State**
- Check off the stage in `todo.md`.
- If a lesson was learned, append to `lessons.md`.

### Self-Correction Protocol

If a test fails or review reveals a problem:

1. Do NOT proceed to the next stage.
2. Diagnose: find the root cause (not a symptom fix).
3. If the fix changes the contract → return to PLAN Phase 2 and re-freeze.
4. **3-Strike Rule**: If 3 fix attempts fail on the same issue, escalate via AskUserQuestion — do not loop silently.

---

## REVIEW Mode

Audit existing code, a PR, or completed work against all 10 rules.

### Procedure

1. Read the diff (`git diff main...HEAD` or specified range) and any `todo.md`/plan files.
2. Check each rule:

| Rule | What to Check |
|------|---------------|
| R1 Boundary | Does the diff stay within declared scope? Classify files as IN_SCOPE / ADJACENT / OUT_OF_SCOPE. |
| R2 Contract | Were shared interfaces modified? Were consumers updated? |
| R3 Dependency | Was the build order correct? Were foundations built before consumers? |
| R4 Staging | Was the work reasonably staged, or was it one oversized pass? |
| R5 Isolation | Was new logic added to shared/core files? Flag shared-core pollution. |
| R6 Review Loop | Was the change reviewed and re-verified? |
| R7 Failure Paths | Do new functions/endpoints handle errors, timeouts, edge cases? |
| R8 Documentation | Do docs match current code truth? Flag stale documentation. |
| R9 Verification | Were tests added/updated? Are smoke tests honest? |
| R10 Distillation | Were patterns extracted? (N/A for most reviews) |

3. Output the audit report:

```
10 DEV RULES: REVIEW REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Rule 1  - Boundary:      PASS | DRIFT | VIOLATION
Rule 2  - Contract:      PASS | UNSTABLE | VIOLATION
Rule 3  - Dependency:    PASS | MISORDERED | VIOLATION
Rule 4  - Staging:       PASS | OVERSIZED | N/A
Rule 5  - Isolation:     PASS | SHARED-CORE-TOUCHED | VIOLATION
Rule 6  - Review Loop:   PASS | INCOMPLETE | VIOLATION
Rule 7  - Failure Paths: PASS | MISSING | VIOLATION
Rule 8  - Documentation: PASS | STALE | VIOLATION
Rule 9  - Verification:  PASS | CEREMONIAL | VIOLATION
Rule 10 - Distillation:  PASS | SKIPPED | N/A
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Verdict: SHIP | SHIP_WITH_CONCERNS | BLOCK

[Details for each non-PASS rule]
```

**Verdict logic**:
- All PASS → **SHIP**
- Any DRIFT/MISSING/STALE/INCOMPLETE/SKIPPED but no VIOLATION → **SHIP_WITH_CONCERNS**
- Any VIOLATION → **BLOCK**

---

## DISTILL Mode

Extract reusable principles from completed work.

### Procedure

1. Read `todo.md`, `lessons.md`, and `git log --oneline -20`.
2. Identify repeated moves across the work: what patterns emerged?
3. Convert each repeated move into a named principle:
   - Strip feature names unless needed for clarity.
   - Use action verbs: scope, freeze, sequence, stage, isolate, review, verify.
   - Format: **Principle name** — why it matters.
4. Write output to `lessons.md` or a designated file.
5. End with a one-line summary formula.

```
10 DEV RULES: DISTILLED PRINCIPLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. [Principle] — [why it matters]
2. [Principle] — [why it matters]
...

Formula: [one-line summary]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Anti-Patterns (Active Signals)

The agent watches for these and intervenes when detected:

| Anti-Pattern | Signal | Agent Response |
|---|---|---|
| Premature system design | User asks to design the full future system when current task has narrow scope | Redirect to Rule 1: set the boundary first |
| Consumer-driven contracts | Consumer is defining interfaces that providers haven't stabilized | Block with Rule 2: freeze the contract from provider side |
| Premature abstraction | User wants to abstract because two things "look similar" | Challenge with Rule 5: abstract only after repeated pressure |
| Ceremonial review | "LGTM" with no substantive check | Reject with Rule 6: define how the change was actually checked |
| History-preserving docs | Documentation preserves old narrative but hides current truth | Flag with Rule 8: separate living specs from history |
| Verification theater | Tests exist but don't test real behavior | Flag with Rule 9: prefer checks that reveal real runtime behavior |

---

## State Files

The agent uses these files to maintain state across sessions. All are optional — the agent creates them as needed.

| File | Purpose | Created by |
|------|---------|-----------|
| `todo.md` | Living task plan with checkboxes | PLAN Phase 4 |
| `lessons.md` | Cross-session learning | DISTILL mode, self-correction |
| `.10dev/boundary.txt` | Scope boundary for hook enforcement (one allowed path per line) | PLAN Phase 1 |
| `.10dev/contract.md` | Frozen contract definitions | PLAN Phase 2 |

---

## Hook: Boundary Guard

The `bin/check-boundary.sh` hook enforces Rule 1 by checking every `Edit` and `Write` against `.10dev/boundary.txt`.

- **No boundary file** → all edits allowed (boundary not yet set)
- **File inside boundary** → allowed
- **File outside boundary** → `permissionDecision: "ask"` with explanation

This is advisory (ask), not blocking (deny), because scope may legitimately expand. The user decides.

To set a boundary manually:
```bash
mkdir -p .10dev
echo "/path/to/allowed/directory" > .10dev/boundary.txt
```

---

## Default Summary Formula

Describe the approach as: **boundary-driven, contract-driven, dependency-ordered, staged, isolated, and closed-loop verified**.
