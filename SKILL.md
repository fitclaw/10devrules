---
name: ten-dev-rules
preamble-tier: 2
version: 2.1.0
description: |
  Agent-driven development workflow using 10 rules as active decision gates.
  Five modes: PLAN, EXECUTE, REVIEW, DISTILL, DOCS.
  Commands: /10plan, /10exec, /10review, /10distill, /10docs.
  Use when asked to "plan a feature", "start a task", "review this code", "what did we learn",
  "sync docs", "doc health", "clean up docs", or any development work that benefits from structured scoping.
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

# Ten Development Rules — Agent Skill v2.1

An active agent cluster that uses 10 rules as decision gates. Each mode's detailed logic lives in `docs/` — read on demand.

## Preamble (run first)

```bash
# Detect project state
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_HAS_BOUNDARY=$([ -f .10dev/boundary.txt ] && echo "yes" || echo "no")
_HAS_TODO=$([ -f todo.md ] && echo "yes" || echo "no")
_HAS_LESSONS=$([ -f lessons.md ] && echo "yes" || echo "no")
_HAS_SYNC_CONFIG=$([ -f .10dev/doc-sync.yaml ] && echo "yes" || echo "no")
echo "BRANCH: $_BRANCH"
echo "BOUNDARY_SET: $_HAS_BOUNDARY"
echo "TODO_EXISTS: $_HAS_TODO"
echo "LESSONS_EXISTS: $_HAS_LESSONS"
echo "SYNC_CONFIG: $_HAS_SYNC_CONFIG"
```

If `BOUNDARY_SET` is `yes`, read `.10dev/boundary.txt` before proceeding — the scope is locked.
If `TODO_EXISTS` is `yes`, read `todo.md` to understand current task state.
If `LESSONS_EXISTS` is `yes`, scan `lessons.md` for relevant prior lessons before starting.

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
| 6 | **Build the review loop** | Every stage includes implement->review->fix->re-verify as one cycle. |
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

## Mode Router

| Command | Signal | Mode | Detail |
|---------|--------|------|--------|
| `/10plan` | "plan", "scope", "design", "architect", "start a task", "begin" | **PLAN** | Read `docs/10plan.md` |
| `/10exec` | "build", "implement", "execute", "code this", "do it" | **EXECUTE** | Read `docs/10exec.md` |
| `/10review` | "review", "audit", "check", "look at this", "PR review" | **REVIEW** | Read `docs/10review.md` |
| `/10distill` | "distill", "retro", "what did we learn", "extract patterns", "summarize" | **DISTILL** | Read `docs/10distill.md` |
| `/10docs` | "sync docs", "doc health", "clean up docs", "archive phase", "rebuild index" | **DOCS** | Read `docs/10docs.md` |

**On mode match**: Read the corresponding detail file from `docs/`, then execute its procedure.

If ambiguous, ask:

```
What mode should I operate in?

A) PLAN — Define scope, contracts, stages, and failure paths before coding
B) EXECUTE — Implement staged work with isolation, review loops, and verification
C) REVIEW — Audit existing code/PR against the 10 rules
D) DISTILL — Extract reusable principles from completed work
E) DOCS — Document health check, cleanup, vault sync, or decision snapshot
```

---

## Output Templates

### PLAN Output

```
10 DEV RULES: PLAN
━━━━━━━━━━━━━━━━━━
Task: [one-line description]

## Boundary (R1)
Solves: ...
Defers: ...
Removed: ...

## WATCH LIST (from developer profile, if any)
⚠ HIGH: [pattern] — [defense]
  - [ ] Acknowledged: [pattern]
MEDIUM: [pattern] — [defense]

## Contract (R2)
[frozen interfaces/types/schemas]

## Dependency Order (R3)
1. [foundation] -> 2. [consumer] -> 3. [integration]

## Stages (R4)
- [ ] Stage 1: [name] | Entry: [cond] | Exit: [cond] | Files: [path1, path2]
- [ ] Stage 2: ...

## Failure Paths (R7)
[per-stage enumeration]

## Validation (R9)
[what will be verified and how]
━━━━━━━━━━━━━━━━━━
```

### EXECUTE Stage Complete

```
STAGE COMPLETE: [name]
━━━━━━━━━━━━━━━━━━━━━
Rule 5 (Isolate):  [new files created / shared code status]
Rule 6 (Review):   [self-review summary]
Rule 9 (Verify):
  Verified: [what was checked]
  Skipped:  [what was not checked and why]
  Risk:     [remaining unknowns]
━━━━━━━━━━━━━━━━━━━━━
```

### REVIEW Report

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
```

### DISTILL Output

```
10 DEV RULES: DISTILLED PRINCIPLES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. [Principle] — [why it matters]
2. [Principle] — [why it matters]
...

Formula: [one-line summary]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### DOCS Health Report

```
DOC-SYNC: HEALTH AUDIT
━━━━━━━━━━━━━━━━━━━━━━
Project: {name} | Phase: {detected}

todo.md:      {N} stale tasks
lessons.md:   {N} untagged / {N} total
contract.md:  {N} drifted interfaces
orphaned:     {list}
━━━━━━━━━━━━━━━━━━━━━━
Health: GREEN | YELLOW | RED
Recommendation: {action}
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
| `lessons.md` | Cross-session learning (L0) | DISTILL mode, self-correction |
| `.10dev/boundary.txt` | Scope boundary for hook enforcement (one allowed path per line) | PLAN Phase 1 |
| `.10dev/contract.md` | Frozen contract definitions | PLAN Phase 2 |
| `.10dev/doc-sync.yaml` | Vault sync configuration | DOCS first-run |
| `.10dev/archive/` | Archived phase snapshots | DOCS CLEANUP |
| `~/.10dev/developer-profile.md` | Global developer blind spots + preferences (L1) | DISTILL bootstrap |
| `~/.10dev/universal-principles.md` | Abstracted universal principles (L2) | DISTILL L1→L2 promotion |
| `~/.10dev/projects.txt` | Global registry of known project paths | PLAN Phase 0 |
| `~/.10dev/.onboarded` | Global onboarding flag | /10dev Phase 1 |
| `~/.10dev/.routing_declined` | User declined CLAUDE.md routing | /10dev Phase 2 |

---

## Tool Commands

These are utility commands, not work modes. They do not appear in the Mode Router table.

| Command | Purpose | Detail |
|---------|---------|--------|
| `/10dev` | Orchestrator — onboarding, project scan, status dashboard | Read `docs/10dev.md` |
| `/10profile` | View/manage developer blind spots and preferences | Read `skills/10profile/SKILL.md` |

---

## Hook: Boundary Guard

The `bin/check-boundary.sh` hook enforces Rule 1 by checking every `Edit` and `Write` against `.10dev/boundary.txt`. No boundary file means all edits are allowed. Files outside boundary trigger an advisory ask (not a block).

---

## Default Summary Formula

Describe the approach as: **boundary-driven, contract-driven, dependency-ordered, staged, isolated, and closed-loop verified**.
