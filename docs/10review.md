# REVIEW Mode

Audit existing code, a PR, or completed work against all 10 rules.

## Procedure

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

3. Output the audit report using the review output template in SKILL.md.

## Verdict Logic

- All PASS -> **SHIP**
- Any DRIFT/MISSING/STALE/INCOMPLETE/SKIPPED but no VIOLATION -> **SHIP_WITH_CONCERNS**
- Any VIOLATION -> **BLOCK**
