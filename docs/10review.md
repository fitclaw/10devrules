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

## Developer Profile Match (if profile exists)

After producing the standard review report, check `~/.10dev/developer-profile.md`:

1. If file exists, read it.
2. For each review finding that is DRIFT, VIOLATION, MISSING, INCOMPLETE, or STALE:
   - Compare the finding's category against blind spot `Keywords` fields.
   - If a match is found, append a profile match note to the report.
3. Append a **Profile Match** section after the verdict:

```
## Profile Match
  R7 MISSING matches known pattern: "Skips failure path design" (seen 2 times)
  R1 DRIFT matches known pattern: "Assumes platform behavior" (seen 3 times)

  Recurring patterns detected: {count} of {total findings} match your profile.
```

4. If no findings match any blind spot, skip this section.
5. The Profile Match section is informational only — it does not change the verdict.

## Verdict Logic

- All PASS -> **SHIP**
- Any DRIFT/MISSING/STALE/INCOMPLETE/SKIPPED but no VIOLATION -> **SHIP_WITH_CONCERNS**
- Any VIOLATION -> **BLOCK**
