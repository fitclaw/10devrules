# EXECUTE Mode

Assumes a plan exists (from PLAN mode or an existing `todo.md`). Runs a stage loop.

## Stage Loop

For each unchecked stage in `todo.md`:

### 1. Isolate (Rule 5)

- Determine if this stage introduces new complexity.
- New domain logic -> create new files/modules. Do NOT modify shared core unless justified.
- The `check-boundary.sh` hook reads `.10dev/boundary.txt` and flags edits outside scope.
- If shared code must change, ask first:

```
This edit touches shared code at [path]. Rule 5: isolate new complexity.

A) Proceed — this shared change is necessary and I'll explain why
B) Refactor — extract to a new file instead
C) Defer — mark as tech debt for later
```

### 2. Implement

- Write the code for this stage following the dependency sequence.
- After implementation, immediately run available tests.

### 3. Review Loop (Rule 6)

- Run `git diff` to see what changed.
- Self-review the diff against the stage's exit conditions.
- If tests exist, run them.
- Parse the current stage's `Files:` field from `todo.md` (comma-separated paths after `Files:`).
- If `Files:` field exists: compare the diff's changed files against the predicted list. Flag any file NOT in the list:

```
File drift detected: {path} was modified but not in the stage's predicted file list.
Rule 5: is this an intentional scope expansion or accidental coupling?

A) Expected — update the stage's Files field
B) Refactor — move this change to a separate stage
C) Revert — this was accidental
```

- If no `Files:` field (legacy format): skip the file drift check for this stage.

### 4. Verify (Rule 9)

Before marking a stage complete, state explicitly using the stage-complete output template in SKILL.md.

**Gate**: Cannot mark a stage done without at least one verification item under "Verified".

### 5. Update State

- Check off the stage in `todo.md`.
- If a lesson was learned, append to `lessons.md`.

## Self-Correction Protocol

If a test fails or review reveals a problem:

1. Do NOT proceed to the next stage.
2. Diagnose: find the root cause (not a symptom fix).
3. If the fix changes the contract -> return to PLAN Phase 2 and re-freeze.
4. **3-Strike Rule**: If 3 fix attempts fail on the same issue, escalate via AskUserQuestion — do not loop silently.
