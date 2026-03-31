# Review Checklist

Use this file when reviewing plans, pull requests, or implemented work with `ten-development-rules`.

## Check These Failure Modes First

### Scope Drift

- Did the change solve more than the task required?
- Were adjacent ideas added without becoming blockers?
- Is the current boundary still explicit?

### Contract Drift

- Did shared types, routes, statuses, or acceptance criteria change without being called out?
- Are consumers depending on behavior that providers have not stabilized?
- Is there one obvious contract source of truth?

### Shared-Core Pollution

- Did new domain logic leak into shared utilities or core modules too early?
- Was abstraction added because of real repeated pressure or just anticipated reuse?

### Missing Failure Handling

- Are unhappy paths handled explicitly?
- What happens on partial input, retry, timeout, auth failure, or concurrency conflict?
- Is rollback or idempotency needed?

### Missing Verification

- Was anything actually exercised or checked?
- Are smoke tests honest?
- Does the reported validation match what was really run?

### Stale Documentation

- Do docs still reflect current truth?
- Is the default reading order obvious?
- Are old narratives overriding the new source of truth?

## Review Output Shape

When reviewing existing work, prefer this order:

1. Findings
2. Open questions or assumptions
3. Short change summary
4. Validation status

## Severity Heuristic

- High: incorrect contract, broken dependency ordering, missing failure-path handling that can cause data loss or inconsistent behavior
- Medium: scope drift, misleading tests, or premature abstraction that will make future work harder
- Low: wording ambiguity, weak documentation routing, or small validation gaps

## Validation Notes To Include

Always say:

- What was reviewed
- What evidence was used
- What was not verified directly
- What still carries risk
