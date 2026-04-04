#!/usr/bin/env bash
# test-detect-env.sh — Unit tests for bin/detect-env.sh
# Run: bash test/test-detect-env.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DETECT="$SCRIPT_DIR/bin/detect-env.sh"
PASS=0
FAIL=0
TOTAL=0

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

assert_test_cmd() {
  local desc="$1" expected="$2"
  TOTAL=$((TOTAL + 1))
  local result
  result=$(cd "$TMPDIR" && bash "$DETECT" 2>/dev/null | grep '^TEST:' | sed 's/^TEST: //')
  if [ "$result" = "$expected" ]; then
    PASS=$((PASS + 1))
    echo "  PASS: $desc"
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: $desc — expected '$expected' got '$result'"
  fi
}

reset_tmp() {
  rm -rf "$TMPDIR"/*
  rm -rf "$TMPDIR"/.*  2>/dev/null || true
}

echo "=== detect-env.sh tests ==="

# Test 1: No framework → none
echo "[1] No framework detected"
reset_tmp
assert_test_cmd "empty dir returns none" "none"

# Test 2: Shell tests detected
echo "[2] Shell test directory"
reset_tmp
mkdir -p "$TMPDIR/test"
touch "$TMPDIR/test/test-foo.sh"
assert_test_cmd "test/*.sh detected" 'for t in test/*.sh; do bash "$t" || exit 1; done'

# Test 3: jest config
echo "[3] Jest config"
reset_tmp
echo '{}' > "$TMPDIR/package.json"
touch "$TMPDIR/jest.config.js"
assert_test_cmd "jest.config.js detected" "npx jest"

# Test 4: vitest config (should win over jest if both present... but first match wins)
echo "[4] Vitest config"
reset_tmp
echo '{}' > "$TMPDIR/package.json"
touch "$TMPDIR/vitest.config.ts"
assert_test_cmd "vitest.config.ts detected" "npx vitest run"

# Test 5: CLAUDE.md override
echo "[5] CLAUDE.md override"
reset_tmp
mkdir -p "$TMPDIR/test"
touch "$TMPDIR/test/test-foo.sh"
cat > "$TMPDIR/CLAUDE.md" << 'EOF'
## Testing

```
bun test
```
EOF
assert_test_cmd "CLAUDE.md ## Testing overrides auto-detect" "bun test"

# Test 6: go.mod
echo "[6] Go project"
reset_tmp
touch "$TMPDIR/go.mod"
assert_test_cmd "go.mod detected" "go test ./..."

echo ""
echo "=== Results: $PASS/$TOTAL passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
