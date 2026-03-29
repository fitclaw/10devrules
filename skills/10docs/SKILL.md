---
name: 10docs
preamble-tier: 2
description: |
  DOCS mode for 10 Development Rules. Document health check, cleanup, vault sync, decision snapshots, and index rebuild.
  Use when asked to "sync docs", "doc health", "clean up docs", "archive phase", "rebuild index", or "what's stale".
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

# 10docs — DOCS Mode

Shortcut into Ten Development Rules **DOCS** mode.

## Preamble (run first)

```bash
# Locate 10dev project root
_10DEV_ROOT="$(readlink ~/.claude/skills/ten-dev-rules 2>/dev/null)"
echo "10DEV_ROOT: ${_10DEV_ROOT}"

# Detect project state
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_HAS_BOUNDARY=$([ -f .10dev/boundary.txt ] && echo "yes" || echo "no")
_HAS_TODO=$([ -f todo.md ] && echo "yes" || echo "no")
_HAS_LESSONS=$([ -f lessons.md ] && echo "yes" || echo "no")
_HAS_SYNC_CONFIG=$([ -f .10dev/doc-sync.yaml ] && echo "yes" || echo "no")
echo "BRANCH: $_BRANCH | BOUNDARY: $_HAS_BOUNDARY | TODO: $_HAS_TODO | LESSONS: $_HAS_LESSONS | SYNC_CONFIG: $_HAS_SYNC_CONFIG"
```

## Procedure

After running the preamble, read these files using the `10DEV_ROOT` path:

1. **Router**: `{10DEV_ROOT}/SKILL.md` — absorb Ten Rules, default stance, output templates, anti-patterns.
2. **Detail**: `{10DEV_ROOT}/docs/10docs.md` — full DOCS mode logic with sub-commands.
3. Execute the DOCS procedure as documented in the detail file.

## Sub-Commands

- `/10docs` or `/10docs audit` — Health audit
- `/10docs cleanup` — Phase-aware archival
- `/10docs sync` — Obsidian vault sync
- `/10docs snapshot` — Decision record (ADR)
- `/10docs index` — Rebuild reading order
