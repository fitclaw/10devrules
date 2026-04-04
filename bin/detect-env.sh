#!/usr/bin/env bash
# detect-env.sh — Shared environment detection for 10devrules.
# Detects test framework, linter, and type checker.
# Outputs: _TEST_CMD, _LINT_CMD, _TYPE_CMD
# Priority: CLAUDE.md ## Testing > first framework match > none
set -euo pipefail

_TEST_CMD=""
_LINT_CMD=""
_TYPE_CMD=""

# --- Test Framework Detection ---

# Priority 1: CLAUDE.md ## Testing section (authoritative override)
if [ -f CLAUDE.md ] && grep -q '## Testing' CLAUDE.md 2>/dev/null; then
  # Extract first code block after ## Testing header
  _TEST_CMD=$(awk '/^## Testing/{found=1; next} found && /^```/{if(in_block){exit}else{in_block=1; next}} found && in_block && /^```/{exit} found && in_block{print; exit}' CLAUDE.md 2>/dev/null || true)
  _TEST_CMD=$(printf '%s' "$_TEST_CMD" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
fi

# Priority 2: Auto-detect (first match wins)
if [ -z "$_TEST_CMD" ]; then
  if [ -f package.json ]; then
    if [ -f vitest.config.ts ] || [ -f vitest.config.js ] || [ -f vitest.config.mts ]; then
      _TEST_CMD="npx vitest run"
    elif [ -f jest.config.js ] || [ -f jest.config.ts ] || [ -f jest.config.mjs ]; then
      _TEST_CMD="npx jest"
    elif grep -q '"test"' package.json 2>/dev/null; then
      _TEST_CMD="npm test"
    fi
  elif [ -f Cargo.toml ]; then
    _TEST_CMD="cargo test"
  elif [ -f go.mod ]; then
    _TEST_CMD="go test ./..."
  elif [ -f pyproject.toml ] || [ -f pytest.ini ] || [ -f setup.py ]; then
    if command -v python3 >/dev/null 2>&1 && python3 -m pytest --version &>/dev/null; then
      _TEST_CMD="python3 -m pytest"
    fi
  elif [ -f Gemfile ]; then
    if [ -f .rspec ]; then
      _TEST_CMD="bundle exec rspec"
    else
      _TEST_CMD="bundle exec rake test"
    fi
  fi
  # Shell test fallback: if test/ dir has .sh files
  if [ -z "$_TEST_CMD" ] && [ -d test/ ]; then
    _SH_COUNT=$(find test/ -maxdepth 1 -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')
    if [ "$_SH_COUNT" -gt 0 ]; then
      _TEST_CMD="for t in test/*.sh; do bash \"\$t\" || exit 1; done"
    fi
  fi
fi

# --- Linter Detection ---
if [ -f eslint.config.js ] || [ -f eslint.config.mjs ] || [ -f .eslintrc.js ] || [ -f .eslintrc.json ] || [ -f .eslintrc.yml ]; then
  _LINT_CMD="npx eslint ."
elif [ -f .ruff.toml ] || ([ -f pyproject.toml ] && grep -q '\[tool.ruff\]' pyproject.toml 2>/dev/null); then
  _LINT_CMD="ruff check ."
elif [ -f .rubocop.yml ]; then
  _LINT_CMD="bundle exec rubocop"
fi
# Shellcheck fallback for projects with shell scripts
if [ -z "$_LINT_CMD" ] && command -v shellcheck >/dev/null 2>&1; then
  _SH_FILES=$(find bin/ -name '*.sh' 2>/dev/null | head -1)
  [ -n "$_SH_FILES" ] && _LINT_CMD="shellcheck bin/*.sh"
fi

# --- Type Checker Detection ---
if [ -f tsconfig.json ]; then
  _TYPE_CMD="npx tsc --noEmit"
elif [ -f pyproject.toml ] && command -v mypy >/dev/null 2>&1; then
  _TYPE_CMD="mypy ."
fi

echo "TEST: ${_TEST_CMD:-none}"
echo "LINT: ${_LINT_CMD:-none}"
echo "TYPE: ${_TYPE_CMD:-none}"
