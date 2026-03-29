---
name: 10distill
preamble-tier: 2
description: |
  DISTILL mode for 10 Development Rules. Extract reusable principles from completed work.
  Use when asked to "distill", "retro", "what did we learn", "extract patterns", or "summarize".
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

# 10distill — DISTILL Mode

Shortcut into Ten Development Rules **DISTILL** mode.

## Preamble (run first)

```bash
_10DEV_ROOT="$(readlink ~/.claude/skills/ten-dev-rules 2>/dev/null)"
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
2. **Detail**: `{10DEV_ROOT}/docs/10distill.md` — full DISTILL mode logic with principle extraction.
3. Execute the DISTILL procedure as documented in the detail file.
