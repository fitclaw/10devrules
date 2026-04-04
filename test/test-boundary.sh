#!/usr/bin/env bash
# test-boundary.sh — Unit tests for bin/check-boundary.sh
# Run: bash test/test-boundary.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$SCRIPT_DIR/bin/check-boundary.sh"
PASS=0
FAIL=0
TOTAL=0

# Setup temp project dir
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
cd "$TMPDIR"
mkdir -p .10dev src secrets

assert_allow() {
  local desc="$1" input="$2"
  TOTAL=$((TOTAL + 1))
  local result
  result=$(printf '%s' "$input" | bash "$HOOK" 2>/dev/null)
  if [ "$result" = '{}' ]; then
    PASS=$((PASS + 1))
    echo "  PASS: $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $desc — expected {} got: $result"
  fi
}

assert_ask() {
  local desc="$1" input="$2"
  TOTAL=$((TOTAL + 1))
  local result
  result=$(printf '%s' "$input" | bash "$HOOK" 2>/dev/null)
  if echo "$result" | grep -q '"permissionDecision"'; then
    PASS=$((PASS + 1))
    echo "  PASS: $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $desc — expected ask, got: $result"
  fi
}

echo "=== check-boundary.sh tests ==="

# Test 1: No boundary file → allow
echo "[1] No boundary file"
assert_allow "should allow when no boundary.txt exists" \
  '{"tool_input":{"file_path":"src/main.ts"}}'

# Test 2: Create boundary, file inside → allow
echo "[2] File inside boundary"
echo "src/" > .10dev/boundary.txt
assert_allow "should allow file inside src/" \
  '{"tool_input":{"file_path":"'"$TMPDIR"'/src/main.ts"}}'

# Test 3: File outside boundary → ask
echo "[3] File outside boundary"
assert_ask "should ask for file outside boundary" \
  '{"tool_input":{"file_path":"'"$TMPDIR"'/secrets/key.txt"}}'

# Test 4: Empty boundary file → allow
echo "[4] Empty boundary file"
> .10dev/boundary.txt
assert_allow "should allow when boundary.txt is empty" \
  '{"tool_input":{"file_path":"'"$TMPDIR"'/secrets/key.txt"}}'

# Test 5: Cannot parse file_path → allow
echo "[5] Unparseable input"
echo "src/" > .10dev/boundary.txt
assert_allow "should allow when file_path cannot be extracted" \
  '{"garbage": true}'

# Test 6: .10dev/ state files always allowed
echo "[6] .10dev/ exemption"
echo "src/" > .10dev/boundary.txt
assert_allow "should allow .10dev/boundary.txt even when not in boundary" \
  '{"tool_input":{"file_path":"'"$TMPDIR"'/.10dev/boundary.txt"}}'

echo ""
echo "=== Results: $PASS/$TOTAL passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
