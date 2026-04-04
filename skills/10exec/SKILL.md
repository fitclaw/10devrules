---
name: 10exec
preamble-tier: 2
description: |
  EXECUTE mode for 10 Development Rules. Implement staged work with isolation, review loops, and verification.
  Use when asked to "build", "implement", "execute", "code this", or "do it".
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

# 10exec — EXECUTE Mode

Shortcut into Ten Development Rules **EXECUTE** mode.

## Preamble (run first)

```bash
source "${CLAUDE_SKILL_DIR}/../../bin/detect-root.sh" 2>/dev/null || {
  _10DEV_ROOT="$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)"
  echo "10DEV_ROOT: ${_10DEV_ROOT}"
}
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_HAS_BOUNDARY=$([ -f .10dev/boundary.txt ] && echo "yes" || echo "no")
_HAS_TODO=$([ -f todo.md ] && echo "yes" || echo "no")
_HAS_LESSONS=$([ -f lessons.md ] && echo "yes" || echo "no")
echo "BRANCH: $_BRANCH | BOUNDARY: $_HAS_BOUNDARY | TODO: $_HAS_TODO | LESSONS: $_HAS_LESSONS"
```

## Procedure

After running the preamble, read these files using the `10DEV_ROOT` path:

1. **Router**: `{10DEV_ROOT}/SKILL.md` — absorb Ten Rules, default stance, output templates, anti-patterns.
2. **Detail**: `{10DEV_ROOT}/docs/10exec.md` — full EXECUTE mode logic with stage loop and self-correction.
3. Execute the EXECUTE procedure as documented in the detail file.
