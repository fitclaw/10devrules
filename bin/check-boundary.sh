#!/usr/bin/env bash
# check-boundary.sh — PreToolUse hook for ten-dev-rules skill (Rule 1: Set the boundary)
# Reads JSON from stdin, checks if file_path is within the declared scope boundary.
# Returns {"permissionDecision":"ask","message":"..."} to warn, or {} to allow.
set -euo pipefail

INPUT=$(cat)

# Locate boundary file — check project-local first, then fallback
BOUNDARY_FILE=""
for candidate in ".10dev/boundary.txt" "${CLAUDE_PROJECT_DIR:-.}/.10dev/boundary.txt"; do
  if [ -f "$candidate" ]; then
    BOUNDARY_FILE="$candidate"
    break
  fi
done

# No boundary file → allow everything (boundary not yet set)
if [ -z "$BOUNDARY_FILE" ]; then
  echo '{}'
  exit 0
fi

# Read allowed paths (one per line, skip empty lines and comments)
ALLOWED_PATHS=()
while IFS= read -r line; do
  line=$(printf '%s' "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  [ -z "$line" ] && continue
  [[ "$line" == \#* ]] && continue
  ALLOWED_PATHS+=("$line")
done < "$BOUNDARY_FILE"

# No paths listed → allow everything
if [ ${#ALLOWED_PATHS[@]} -eq 0 ]; then
  echo '{}'
  exit 0
fi

# Extract file_path from tool_input JSON
FILE_PATH=$(printf '%s' "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*:[[:space:]]*"//;s/"$//' || true)

# Python fallback if grep returned empty
if [ -z "$FILE_PATH" ]; then
  FILE_PATH=$(printf '%s' "$INPUT" | python3 -c 'import sys,json; d=json.loads(sys.stdin.read()); print(d.get("tool_input",{}).get("file_path",""))' 2>/dev/null || true)
fi

# Could not extract file path → allow (don't block on parse failure)
if [ -z "$FILE_PATH" ]; then
  echo '{}'
  exit 0
fi

# Resolve to absolute path and canonicalize (handles ../ traversal)
case "$FILE_PATH" in
  /*) ;;
  *) FILE_PATH="$(pwd)/$FILE_PATH" ;;
esac
FILE_PATH=$(realpath -m "$FILE_PATH" 2>/dev/null || printf '%s' "$FILE_PATH" | sed 's|/\+|/|g;s|/$||')

# Always allow writes to .10dev/ state files (boundary.txt, contract.md, etc.)
case "$FILE_PATH" in
  */.10dev/*) echo '{}'; exit 0 ;;
esac

# Check: does the file path start with any allowed path?
for allowed in "${ALLOWED_PATHS[@]}"; do
  # Resolve allowed path to absolute
  case "$allowed" in
    /*) ;;
    *) allowed="$(pwd)/$allowed" ;;
  esac
  allowed=$(realpath -m "$allowed" 2>/dev/null || printf '%s' "$allowed" | sed 's|/\+|/|g;s|/$||')

  # Ensure match requires directory boundary (append / for comparison)
  # This prevents /src matching /src-old
  if [ "$FILE_PATH" = "$allowed" ] || case "$FILE_PATH" in "${allowed}/"*) true;; *) false;; esac; then
    # Inside boundary → allow
    echo '{}'
    exit 0
  fi
done

# Outside all allowed paths → ask (advisory, not blocking)
printf '{"permissionDecision":"ask","message":"[Rule 1: Boundary] This edit targets %s which is outside the declared scope boundary. The allowed paths are defined in .10dev/boundary.txt. Proceed anyway?"}\n' "$FILE_PATH"
