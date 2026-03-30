---
name: 10plan
preamble-tier: 2
description: |
  PLAN mode for 10 Development Rules. Define scope, contracts, stages, and failure paths before coding.
  Reads developer profile for proactive blind spot warnings (WATCH LIST).
  Use when asked to "plan a feature", "scope this", "design the approach", "start a task", or "begin".
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

# 10plan — PLAN Mode

Shortcut into Ten Development Rules **PLAN** mode.

## Preamble (run first)

```bash
_10DEV_ROOT="$(readlink ~/.claude/skills/ten-dev-rules 2>/dev/null)"
echo "10DEV_ROOT: ${_10DEV_ROOT}"
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_HAS_BOUNDARY=$([ -f .10dev/boundary.txt ] && echo "yes" || echo "no")
_HAS_TODO=$([ -f todo.md ] && echo "yes" || echo "no")
_HAS_LESSONS=$([ -f lessons.md ] && echo "yes" || echo "no")
_HAS_PROFILE=$([ -f ~/.10dev/developer-profile.md ] && echo "yes" || echo "no")
_HAS_PRINCIPLES=$([ -f ~/.10dev/universal-principles.md ] && echo "yes" || echo "no")
echo "BRANCH: $_BRANCH | BOUNDARY: $_HAS_BOUNDARY | TODO: $_HAS_TODO | LESSONS: $_HAS_LESSONS"
echo "PROFILE: $_HAS_PROFILE | PRINCIPLES: $_HAS_PRINCIPLES"
```

## Procedure

After running the preamble, read these files using the `10DEV_ROOT` path:

1. **Router**: `{10DEV_ROOT}/SKILL.md` — absorb Ten Rules, default stance, output templates, anti-patterns.
2. **Detail**: `{10DEV_ROOT}/docs/10plan.md` — full PLAN mode logic with 7 phases and gates.
3. If `PROFILE` is `yes`, read `~/.10dev/developer-profile.md` for Phase 0 and Phase 6 (WATCH LIST).
4. If `PRINCIPLES` is `yes`, read `~/.10dev/universal-principles.md` for additional context.
5. Execute the PLAN procedure as documented in the detail file.
