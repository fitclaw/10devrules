#!/usr/bin/env bash
# test-smoke.sh — Structural integrity checks for 10devrules
# Run: bash test/test-smoke.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0
TOTAL=0

check() {
  local desc="$1"
  TOTAL=$((TOTAL + 1))
  if eval "$2" >/dev/null 2>&1; then
    PASS=$((PASS + 1))
    echo "  PASS: $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $desc"
  fi
}

echo "=== Smoke tests ==="

# All skill SKILL.md files exist and have valid YAML frontmatter
echo "[1] Skill SKILL.md files"
for skill in 10dev 10distill 10docs 10exec 10plan 10profile 10review; do
  check "skills/$skill/SKILL.md exists" "[ -f '$SCRIPT_DIR/skills/$skill/SKILL.md' ]"
  check "skills/$skill/SKILL.md has name: field" "head -10 '$SCRIPT_DIR/skills/$skill/SKILL.md' | grep -q '^name:'"
done

# All docs/*.md files exist and are non-empty
echo "[2] Documentation files"
for doc in 10dev 10distill 10docs 10exec 10plan 10review state-files; do
  check "docs/$doc.md exists" "[ -f '$SCRIPT_DIR/docs/$doc.md' ]"
  check "docs/$doc.md is non-empty" "[ -s '$SCRIPT_DIR/docs/$doc.md' ]"
done

# All bin/*.sh files are executable
echo "[3] Shell scripts"
for script in check-boundary.sh detect-root.sh detect-env.sh doc-health-audit.sh doc-sync.sh doc-toc-gen.sh doc-soot-check.sh doc-drift-check.sh; do
  check "bin/$script exists" "[ -f '$SCRIPT_DIR/bin/$script' ]"
  check "bin/$script is executable" "[ -x '$SCRIPT_DIR/bin/$script' ]"
done

# SKILL.md version consistency
echo "[4] Version consistency"
FRONTMATTER_VER=$(head -10 "$SCRIPT_DIR/SKILL.md" | grep '^version:' | awk '{print $2}')
HEADING_VER=$(grep '^# Ten Development Rules' "$SCRIPT_DIR/SKILL.md" | grep -o 'v[0-9][0-9.]*')
check "SKILL.md frontmatter version matches heading" "[ 'v$FRONTMATTER_VER' = '$HEADING_VER' ]"

echo ""
echo "=== Results: $PASS/$TOTAL passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
