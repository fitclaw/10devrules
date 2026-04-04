# EXECUTE Mode

Implement staged work with real verification, code review, and self-correction.

Assumes a plan exists (from /10plan or an existing `todo.md` with stages).

## Phase 0: Environment Detection

Detect available test, lint, and type-check tools before starting any stage.

```bash
source "${_10DEV_ROOT}/bin/detect-env.sh" 2>/dev/null || {
  echo "TEST: none"
  echo "LINT: none"
  echo "TYPE: none"
}
```

Parse the output into `_TEST_CMD`, `_LINT_CMD`, `_TYPE_CMD`. Display:

```
ENVIRONMENT
━━━━━━━━━━━
Tests: {_TEST_CMD or "not available"}
Lint:  {_LINT_CMD or "not available"}
Types: {_TYPE_CMD or "not available"}
```

If all three are "not available", warn: "No verification tools detected. Code review will be the only quality gate."

## Stage Loop

For each unchecked stage in `todo.md`:

### Step 1: Pre-flight

1. Parse the stage line: `- [ ] Stage N: {name} | Entry: {cond} | Exit: {cond} | Files: {paths}`
2. **Entry condition gate**: Verify the entry condition is met. If not:

```
BLOCKED: Stage "{name}" entry condition not met.
  Required: {entry condition}
  Current state: {what's actually true}

Cannot proceed until entry condition is satisfied.
```

3. **WATCH LIST check**: If `~/.10dev/developer-profile.md` exists, check if this stage's description matches any blind spot keywords. If matched, display the warning inline:

```
⚠ WATCH: "{blind spot name}" may apply to this stage.
  Defense: {defense action}
```

### Step 2: Implement

1. Write the code for this stage following the dependency sequence from the plan.
2. **Rule 5 (Isolate)**: New domain logic goes in new files/modules. Do NOT modify shared core unless justified. If shared code must change:

```
This edit touches shared code at {path}. Rule 5: isolate new complexity.

A) Proceed — this shared change is necessary
B) Refactor — extract to a new file instead
C) Defer — mark as tech debt
```

3. After each logical unit of implementation, run `_TEST_CMD` (if available) to catch regressions early. Do not wait until the full stage is done.

### Step 3: Verify (Rule 9)

Run all available verification tools and report concrete numbers:

```bash
# Run each tool, capture exit code and output
```

Output:

```
VERIFICATION: Stage {N}
━━━━━━━━━━━━━━━━━━━━━━
Tests:  {X passed, Y failed} | {command}
Lint:   {X warnings, Y errors} | {command}
Types:  {X errors} | {command}
━━━━━━━━━━━━━━━━━━━━━━
```

**Gate**: If any test fails OR any lint/type error exists:
- Do NOT proceed to Step 4
- Enter Self-Correction Protocol (see below)

If a tool is not available, show "not available" (not a gate).

### Step 4: Stage Review

After verification passes, review this stage's code changes. This is a **focused review**, not the full /10review. Scope: only the files changed in this stage.

**Read `{10DEV_ROOT}/docs/10review.md` for the review dimensions** (Phase 2: Deep Code Review sections A-D). Apply them to this stage's diff.

#### 4a. Rule Checks (3 rules, not 10)

| Rule | What to Check |
|------|---------------|
| R5 Isolation | Were new files created for new logic? Was shared core modified without justification? Cite specific files. |
| R7 Failure Paths | Does every new function/endpoint handle errors? Cite each function and its error handling. |
| R9 Verification | Are there tests for every new codepath? Cite test files and what they cover. |

#### 4b. Deep Code Review

For each modified file in this stage's diff, review:

- **Logic correctness**: branches, null checks, loop termination, return values
- **Boundary conditions**: empty input, platform differences (macOS vs Linux), shell compat (bash vs zsh)
- **Security**: unquoted variables, path traversal, sensitive info in logs
- **Error handling**: external command failures, pipe behavior under `set -e`, cleanup on error

Output format:

```
STAGE REVIEW: {stage name}
━━━━━━━━━━━━━━━━━━━━━━━━
R5 Isolation:     {PASS / SHARED-CORE-TOUCHED — cite file:line}
R7 Failure Paths: {PASS / MISSING — cite function without error handling}
R9 Verification:  {PASS / GAP — cite untested codepath}

Code Review:
  [P1] (confidence: N/10) file:line — description
  [P2] ...
  ✓ {file} — no issues. Checked: {what}

Verdict: CONTINUE | FIX_REQUIRED | BLOCK
━━━━━━━━━━━━━━━━━━━━━━━━
```

**Severity → action:**
- **P1** (will cause bugs): FIX_REQUIRED. Enter Self-Correction.
- **P2** (correctness concern): Show to user via AskUserQuestion. User decides fix or accept.
- **P3** (minor): Note for awareness. CONTINUE.
- Any rule VIOLATION or MISSING: FIX_REQUIRED.

**Self-check**: If review produced no findings AND stage has > 20 changed lines, re-examine. A 20+ line change with zero findings is suspicious. Re-read each file's diff line by line and confirm each function was actually checked.

### Step 5: Commit (with confirmation)

After review passes (verdict: CONTINUE), offer to commit:

```
Stage {N} "{name}" is complete and reviewed.

A) Commit this stage — "stage N: {name} — {one-line summary}"
B) Don't commit yet — I want to review the changes first
C) Squash with next stage — combine into one commit later
```

On commit:
- `git add` the specific files for this stage
- `git commit` with the message
- Check off the stage in `todo.md`: `- [ ]` → `- [x]`

If the user learned something during this stage, append to `lessons.md`.

### Self-Correction Protocol

When Step 3 (Verify) or Step 4 (Review) blocks progress:

1. **Do NOT proceed to the next stage.**
2. **Diagnose root cause**, not symptoms. Read the error/finding carefully.
3. **Fix the issue.** Then re-run Step 3 (Verify) from scratch.
4. If the fix changes a frozen contract (types, interfaces, API surface) → pause and warn:

```
This fix changes a frozen contract. Return to /10plan Phase 2 to re-freeze?

A) Yes — re-freeze contracts, then resume execution
B) No — this is a minor signature change, proceed
```

5. **3-Strike Rule**: If the same issue persists after 3 fix attempts, STOP. Escalate via AskUserQuestion:

```
3 attempts to fix this issue have failed. Escalating.

Issue: {description}
Attempts: {what was tried}
Current state: {what's broken}

A) Try a different approach — {suggest alternative}
B) Skip this stage — mark as blocked, continue to next
C) Abort execution — return to /10plan to re-scope
```

## All Stages Complete

When all stages in `todo.md` are checked:

1. Run the full `_TEST_CMD` to verify nothing regressed across stages.
2. Output the execution summary:

```
10 DEV RULES: EXECUTION SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Stages: {N} completed, {M} self-corrections
Verification:
  Tests:  {total pass/fail}
  Lint:   {total warnings/errors}
  Types:  {total errors}
Stage Reviews:
  Findings: P1: {X}, P2: {Y}, P3: {Z}
  All resolved: {yes/no}
Commits: {N} atomic commits

Next steps:
  1. /10review — full 10-rule audit on the complete diff
  2. /10distill — extract lessons from this work
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
