# REVIEW Mode

Audit existing code, a PR, or completed work against all 10 rules — then verify with real code review.

Two phases: compliance audit (10 rules) → deep code review (per-file analysis). A self-check gate between the two phases catches shallow reviews and auto-triggers the deep review when needed.

## Phase 1: 10-Rule Compliance Audit

1. Detect the base branch, then read the diff:
   ```bash
   _BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
   [ -z "$_BASE" ] && git rev-parse --verify origin/main &>/dev/null && _BASE="main"
   [ -z "$_BASE" ] && git rev-parse --verify origin/master &>/dev/null && _BASE="master"
   [ -z "$_BASE" ] && _BASE="main"
   echo "BASE: $_BASE"
   ```
   Read the diff (`git diff $_BASE...HEAD` or `git diff` for uncommitted changes) and any `todo.md`/plan files.

2. Check each rule. **Every non-N/A assessment MUST cite at least one specific file:line as evidence.** A PASS without evidence is a shallow PASS.

| Rule | What to Check |
|------|---------------|
| R1 Boundary | Does the diff stay within declared scope? Classify files as IN_SCOPE / ADJACENT / OUT_OF_SCOPE. Cite the specific files. |
| R2 Contract | Were shared interfaces modified? Were consumers updated? Cite the interface file:line. |
| R3 Dependency | Was the build order correct? Were foundations built before consumers? Cite the dependency chain. |
| R4 Staging | Was the work reasonably staged, or was it one oversized pass? Cite commit count and scope. |
| R5 Isolation | Was new logic added to shared/core files? Cite any shared-core file:line touched. |
| R6 Review Loop | Was the change reviewed and re-verified? Cite test runs or review artifacts. |
| R7 Failure Paths | Do new functions/endpoints handle errors, timeouts, edge cases? Cite each new function and its error handling (or lack thereof). |
| R8 Documentation | Do docs match current code truth? Cite any doc:line that drifted. |
| R9 Verification | Were tests added/updated? Are smoke tests honest? Cite test files and what they cover. |
| R10 Distillation | Were patterns extracted? (N/A for most reviews) |

3. Output the audit report using the review output template in SKILL.md.

## Self-Check Gate

After completing Phase 1, the agent MUST self-check before proceeding.

**Count shallow assessments:**

```
shallow_count = 0
for each rule assessment (excluding N/A):
    if verdict is PASS and analysis text contains no file:line reference:
        shallow_count += 1
    if verdict is not PASS and analysis text contains no file:line reference:
        shallow_count += 2  # worse: found an issue but can't point to it
```

**Trigger conditions (ANY triggers Phase 2):**

1. `shallow_count >= 3` — too many assessments without concrete evidence
2. diff exceeds 50 changed lines AND all rules are PASS — statistically suspicious
3. diff contains shell scripts (.sh), security-sensitive files, or config changes — always warrants deep review

**If triggered:**

```
⚠ SELF-CHECK TRIGGERED: {reason}
Entering deep code review...
```

Proceed to Phase 2 automatically. Do NOT ask the user.

**If not triggered:**

```
✓ Self-check passed: {N} rules cited specific code references.
```

Skip Phase 2. Proceed to Profile Match and output.

## Phase 2: Deep Code Review

Read the full diff again. For **each modified file**, perform a line-by-line review covering these dimensions:

### A. Logic Correctness
- Are all conditional branches covered? (if without else, switch without default)
- Can variables be null/undefined/empty at point of use?
- Do loops have termination conditions?
- Are return values checked?
- Are comparisons correct? (= vs ==, string vs numeric in shell)

### B. Boundary Conditions
- Empty input, zero-length strings, missing files
- Platform differences (macOS vs Linux: `realpath`, `sed -i`, `grep -P`, `readlink`)
- Shell differences (bash vs zsh: glob behavior, array syntax)
- External command availability (`which`/`command -v` before use)
- Path edge cases: spaces, unicode, symlinks, `../` traversal

### C. Security
- Unquoted variables in shell (command injection via `$VAR` without quotes)
- Path traversal (user input in file paths without canonicalization)
- Sensitive information in error messages or logs
- Permissions on created files (umask, chmod)

### D. Error Handling
- Does every external command call handle failure? (`|| true`, `2>/dev/null`, explicit check)
- `set -e` behavior with pipes (`set -o pipefail`?)
- Silent failures vs explicit failures — which is intended?
- Cleanup on error (trap for temp files)

### E. Concurrency & State
- Race conditions on shared files
- Atomic operations where needed
- Stale reads (read → modify → write without lock)

### Output Format

For each file, produce findings:

```
## Code Review: {filename}
Lines changed: +{N} -{M}

[P1] (confidence: 9/10) file:line — description + suggested fix
[P2] (confidence: 7/10) file:line — description
[P3] (confidence: 6/10) file:line — description

✓ {aspect} checked, no issues: {what was specifically verified}
```

Severity levels:
- **P1**: Will cause bugs or security issues in production. Blocks ship.
- **P2**: Correctness concern or missed edge case. Ships with concerns.
- **P3**: Style, minor improvement, or low-probability edge case. Ships clean.

**Confidence calibration:**
- 9-10: Verified by reading specific code. Concrete bug demonstrated.
- 7-8: High confidence pattern match.
- 5-6: Possible false positive. Mark with caveat.
- Below 5: Suppress unless P1 severity.

If a file has no findings after thorough review, state what was checked:
```
✓ {filename} — no issues. Checked: logic branches, error handling, platform compat, quoting.
```

## Developer Profile Match (if profile exists)

After producing the review (Phase 1 + optional Phase 2), check `~/.10dev/developer-profile.md`:

1. If file exists, read it.
2. For each review finding (DRIFT, VIOLATION, MISSING, INCOMPLETE, STALE from Phase 1, or P1/P2 from Phase 2):
   - Compare the finding's category against blind spot `Keywords` fields.
   - If a match is found, append a profile match note to the report.
3. Append a **Profile Match** section after the verdict:

```
## Profile Match
  R7 MISSING matches known pattern: "Skips failure path design" (seen 2 times)
  [P1] realpath compat matches known pattern: "未验证假设导致返工" (seen 3 times)

  Recurring patterns detected: {count} of {total findings} match your profile.
```

4. If no findings match any blind spot, skip this section.
5. The Profile Match section is informational only — it does not change the verdict.

## Verdict Logic

**From Phase 1 (10-rule audit):**
- All PASS → base verdict: SHIP
- Any DRIFT/MISSING/STALE/INCOMPLETE/SKIPPED but no VIOLATION → base verdict: SHIP_WITH_CONCERNS
- Any VIOLATION → base verdict: BLOCK

**From Phase 2 (code review), if triggered:**
- Any P1 finding → upgrade verdict to BLOCK (regardless of Phase 1)
- Any P2 finding → upgrade verdict to at least SHIP_WITH_CONCERNS
- P3 only → no verdict change

Final verdict is the more severe of Phase 1 and Phase 2.

## Output Template

```
10 DEV RULES: REVIEW REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Rule 1  - Boundary:      PASS | DRIFT | VIOLATION    [file:line evidence]
Rule 2  - Contract:      PASS | UNSTABLE | VIOLATION  [file:line evidence]
Rule 3  - Dependency:    PASS | MISORDERED | VIOLATION [evidence]
Rule 4  - Staging:       PASS | OVERSIZED | N/A        [evidence]
Rule 5  - Isolation:     PASS | SHARED-CORE-TOUCHED    [evidence]
Rule 6  - Review Loop:   PASS | INCOMPLETE | VIOLATION [evidence]
Rule 7  - Failure Paths: PASS | MISSING | VIOLATION    [evidence]
Rule 8  - Documentation: PASS | STALE | VIOLATION      [evidence]
Rule 9  - Verification:  PASS | CEREMONIAL | VIOLATION [evidence]
Rule 10 - Distillation:  PASS | SKIPPED | N/A          [evidence]
━━━━━━━━━━━━━━━━━━━━━━━━━━━
Self-check: PASSED ({N} rules with evidence) | TRIGGERED ({reason})

## Code Review Findings (if Phase 2 ran)
{per-file findings}

## Profile Match
{if any findings match blind spots}

━━━━━━━━━━━━━━━━━━━━━━━━━━━
Verdict: SHIP | SHIP_WITH_CONCERNS | BLOCK
Code review: {N} findings (P1: {X}, P2: {Y}, P3: {Z}) | skipped (self-check passed)
```
