---
name: 10dev
preamble-tier: 2
description: |
  10dev orchestrator — environment manager, onboarding, and status dashboard.
  Entry point for new users. Detects state, guides setup, then delegates to work modes.
  Use when asked to "10dev", "setup 10dev", "10dev status", "get started with 10dev",
  or when a user runs 10dev for the first time in a project.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
---

# /10dev — Orchestrator Entry Point

Environment manager and onboarding for 10 Development Rules.

## Preamble (run first)

```bash
_10DEV_ROOT="$(readlink ~/.claude/skills/ten-dev-rules 2>/dev/null || echo "")"
[ -z "$_10DEV_ROOT" ] && [ -f "${CLAUDE_SKILL_DIR}/../../SKILL.md" ] && _10DEV_ROOT="$(cd "${CLAUDE_SKILL_DIR}/../.." && pwd)"
[ -z "$_10DEV_ROOT" ] && _10DEV_ROOT="$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)"
echo "10DEV_ROOT: ${_10DEV_ROOT}"

# Global state
_ONBOARDED=$([ -f ~/.10dev/.onboarded ] && echo "yes" || echo "no")
_HAS_PROFILE=$([ -f ~/.10dev/developer-profile.md ] && echo "yes" || echo "no")
_ROUTING_DECLINED=$([ -f ~/.10dev/.routing_declined ] && echo "yes" || echo "no")
_PROJECT_COUNT=$([ -f ~/.10dev/projects.txt ] && wc -l < ~/.10dev/projects.txt | tr -d ' ' || echo "0")

# Project state
_HAS_10DEV=$([ -d .10dev ] && echo "yes" || echo "no")
_HAS_BOUNDARY=$([ -f .10dev/boundary.txt ] && echo "yes" || echo "no")
_HAS_TODO=$([ -f todo.md ] && echo "yes" || echo "no")
_HAS_LESSONS=$([ -f lessons.md ] && echo "yes" || echo "no")
_HAS_CONTRACT=$([ -f .10dev/contract.md ] && echo "yes" || echo "no")
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")

# CLAUDE.md routing
_HAS_ROUTING="no"
[ -f CLAUDE.md ] && grep -q "## Skill routing — 10dev" CLAUDE.md 2>/dev/null && _HAS_ROUTING="yes"

echo "ONBOARDED: $_ONBOARDED | PROFILE: $_HAS_PROFILE | PROJECTS: $_PROJECT_COUNT"
echo "PROJECT_10DEV: $_HAS_10DEV | BOUNDARY: $_HAS_BOUNDARY | TODO: $_HAS_TODO | LESSONS: $_HAS_LESSONS"
echo "ROUTING: $_HAS_ROUTING | ROUTING_DECLINED: $_ROUTING_DECLINED"
echo "BRANCH: $_BRANCH"
```

## Procedure

After running the preamble, read `{10DEV_ROOT}/docs/10dev.md` for the full orchestrator logic.

Use the preamble output to determine which phase to enter:
- `ONBOARDED=no` → start from Phase 1 (welcome)
- `ONBOARDED=yes` + `PROJECT_10DEV=no` → start from Phase 3 (project scan)
- `ONBOARDED=yes` + `PROJECT_10DEV=yes` → Phase 5 (dashboard)

Subcommand overrides:
- `/10dev setup` → delete `~/.10dev/.onboarded` and restart from Phase 1
- `/10dev status` → jump to Phase 5 (dashboard)

When Phase 4 asks the user to pick a skill, read and execute it inline from `{10DEV_ROOT}/skills/{choice}/SKILL.md`.
