#!/usr/bin/env bash
# detect-root.sh — Shared 10DEV_ROOT detection for all skill preambles.
# Sources this file to set _10DEV_ROOT. Three fallback strategies:
#   1. Symlink at ~/.claude/skills/ten-dev-rules
#   2. CLAUDE_SKILL_DIR relative path (../../)
#   3. Glob fallback: search ~/.claude/skills/*/SKILL.md for name: ten-dev-rules
set -euo pipefail

_10DEV_ROOT=""

# Strategy 1: known symlink name
[ -z "$_10DEV_ROOT" ] && _10DEV_ROOT="$(readlink ~/.claude/skills/ten-dev-rules 2>/dev/null || echo "")"

# Strategy 2: CLAUDE_SKILL_DIR relative path
[ -z "$_10DEV_ROOT" ] && [ -f "${CLAUDE_SKILL_DIR:-}/../../SKILL.md" ] && _10DEV_ROOT="$(cd "${CLAUDE_SKILL_DIR}/../.." && pwd)"

# Strategy 3: glob fallback — search for SKILL.md containing "name: ten-dev-rules"
if [ -z "$_10DEV_ROOT" ]; then
  for _candidate in ~/.claude/skills/*/SKILL.md; do
    [ -f "$_candidate" ] || continue
    if head -5 "$_candidate" | grep -q "name: ten-dev-rules" 2>/dev/null; then
      _10DEV_ROOT="$(cd "$(dirname "$_candidate")" && pwd)"
      break
    fi
  done
fi

# Strategy 4: dirname fallback (for direct execution)
[ -z "$_10DEV_ROOT" ] && _10DEV_ROOT="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)"

echo "10DEV_ROOT: ${_10DEV_ROOT}"
