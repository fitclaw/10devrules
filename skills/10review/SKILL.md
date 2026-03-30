---
name: 10review
preamble-tier: 2
description: |
  REVIEW mode for 10 Development Rules. Audit existing code/PR against the 10 rules.
  Use when asked to "review", "audit", "check", "look at this", or "PR review".
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
          command: "bash ${CLAUDE_SKILL_DIR}/../../bin/check-boundary.sh"
          statusMessage: "Rule 1: Checking scope boundary..."
    - matcher: "Write"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/../../bin/check-boundary.sh"
          statusMessage: "Rule 1: Checking scope boundary..."
---

# 10review — REVIEW Mode

Shortcut into Ten Development Rules **REVIEW** mode.

## Preamble (run first)

```bash
_10DEV_ROOT="$(readlink ~/.claude/skills/ten-dev-rules 2>/dev/null || echo "")"
[ -z "$_10DEV_ROOT" ] && [ -f "${CLAUDE_SKILL_DIR}/../../SKILL.md" ] && _10DEV_ROOT="$(cd "${CLAUDE_SKILL_DIR}/../.." && pwd)"
[ -z "$_10DEV_ROOT" ] && _10DEV_ROOT="$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)"
echo "10DEV_ROOT: ${_10DEV_ROOT}"
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_HAS_BOUNDARY=$([ -f .10dev/boundary.txt ] && echo "yes" || echo "no")
_HAS_TODO=$([ -f todo.md ] && echo "yes" || echo "no")
_HAS_LESSONS=$([ -f lessons.md ] && echo "yes" || echo "no")
echo "BRANCH: $_BRANCH | BOUNDARY: $_HAS_BOUNDARY | TODO: $_HAS_TODO | LESSONS: $_HAS_LESSONS"
```

## Procedure

After running the preamble, read these files using the `10DEV_ROOT` path:

1. **Router**: `{10DEV_ROOT}/SKILL.md` — absorb Ten Rules, default stance, output templates, anti-patterns.
2. **Detail**: `{10DEV_ROOT}/docs/10review.md` — full REVIEW mode logic with 10-rule audit and verdict.
3. Execute the REVIEW procedure as documented in the detail file.
