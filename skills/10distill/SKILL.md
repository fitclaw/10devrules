---
name: 10distill
preamble-tier: 2
description: |
  DISTILL mode for 10 Development Rules. Extract reusable principles from completed work.
  Updates developer profile with recurring blind spots. Supports cross-project pattern detection.
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
source "${CLAUDE_SKILL_DIR}/../../bin/detect-root.sh" 2>/dev/null || {
  _10DEV_ROOT="$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)"
  echo "10DEV_ROOT: ${_10DEV_ROOT}"
}
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_HAS_BOUNDARY=$([ -f .10dev/boundary.txt ] && echo "yes" || echo "no")
_HAS_TODO=$([ -f todo.md ] && echo "yes" || echo "no")
_HAS_LESSONS=$([ -f lessons.md ] && echo "yes" || echo "no")
_HAS_PROFILE=$([ -f ~/.10dev/developer-profile.md ] && echo "yes" || echo "no")
_HAS_PROJECTS=$([ -f ~/.10dev/projects.txt ] && echo "yes" || echo "no")
_PROJECT_COUNT=$([ -f ~/.10dev/projects.txt ] && wc -l < ~/.10dev/projects.txt | tr -d ' ' || echo "0")
echo "BRANCH: $_BRANCH | BOUNDARY: $_HAS_BOUNDARY | TODO: $_HAS_TODO | LESSONS: $_HAS_LESSONS"
echo "PROFILE: $_HAS_PROFILE | PROJECTS_REGISTERED: $_PROJECT_COUNT"
```

## Procedure

After running the preamble, read these files using the `10DEV_ROOT` path:

1. **Router**: `{10DEV_ROOT}/SKILL.md` — absorb Ten Rules, default stance, output templates, anti-patterns.
2. **Detail**: `{10DEV_ROOT}/docs/10distill.md` — full DISTILL mode logic with 4 phases.
3. If `PROFILE` is `yes`, read `~/.10dev/developer-profile.md` for Phase 2 (profile comparison).
4. Execute the DISTILL procedure as documented in the detail file.
5. If user says `/10distill export`, execute Phase 4 (Profile Export) from the detail file.
