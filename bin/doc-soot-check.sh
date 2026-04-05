#!/usr/bin/env bash
# doc-soot-check.sh — Single Source of Truth checker for ten-dev-rules DOCS mode
# Detects terms/definitions that appear in multiple markdown files.
# Usage: doc-soot-check.sh [project_root]
# Output: JSON with duplications list and count.
set -euo pipefail

PROJECT_ROOT="${1:-.}"
cd "$PROJECT_ROOT"

# Collect all markdown files (root + docs/, excluding archive and node_modules)
MD_FILES=""
for f in *.md docs/*.md; do
  [ -f "$f" ] || continue
  case "$f" in
    docs/archive/*) continue ;;
  esac
  MD_FILES="$MD_FILES $f"
done

# Extract definition-like terms from all files
# Patterns: "- **Term**:", "| Term |", "type/interface/class Name"
TERMS_FILE=$(mktemp)
trap 'rm -f "$TERMS_FILE"' EXIT

for f in $MD_FILES; do
  # Bold definitions: - **Term**: or - **Term** —
  grep -oE '\*\*[A-Za-z][A-Za-z0-9_ .-]+\*\*' "$f" 2>/dev/null | sed 's/\*\*//g' | while IFS= read -r term; do
    # Only terms with 2+ words or specific enough single words (>4 chars)
    if [ "${#term}" -gt 4 ]; then
      printf '%s\t%s\n' "$term" "$f"
    fi
  done || true
done | sort > "$TERMS_FILE"

# Find terms that appear in multiple files
DUPLICATIONS=""
DUP_COUNT=0
SEEN_TERMS=""

# Group by term, find those in 2+ files
prev_term=""
prev_files=""
while IFS=$'\t' read -r term file; do
  if [ "$term" = "$prev_term" ]; then
    # Same term, different file?
    case "$prev_files" in
      *"$file"*) ;; # Already seen this file
      *)
        prev_files="$prev_files, $file"
        ;;
    esac
  else
    # New term — emit previous if it was in multiple files
    if [ -n "$prev_term" ] && echo "$prev_files" | grep -q ','; then
      # Check we haven't already emitted this term
      case "$SEEN_TERMS" in
        *"|$prev_term|"*) ;;
        *)
          if [ "$DUP_COUNT" -gt 0 ]; then
            DUPLICATIONS="$DUPLICATIONS,"
          fi
          # Escape quotes for JSON
          escaped_term=$(printf '%s' "$prev_term" | sed 's/"/\\"/g')
          escaped_files=$(printf '%s' "$prev_files" | sed 's/"/\\"/g')
          DUPLICATIONS="$DUPLICATIONS
    {\"term\": \"$escaped_term\", \"files\": \"$escaped_files\"}"
          DUP_COUNT=$((DUP_COUNT + 1))
          SEEN_TERMS="$SEEN_TERMS|$prev_term|"
          ;;
      esac
    fi
    prev_term="$term"
    prev_files="$file"
  fi
done < "$TERMS_FILE"

# Don't forget the last term
if [ -n "$prev_term" ] && echo "$prev_files" | grep -q ','; then
  case "$SEEN_TERMS" in
    *"|$prev_term|"*) ;;
    *)
      if [ "$DUP_COUNT" -gt 0 ]; then
        DUPLICATIONS="$DUPLICATIONS,"
      fi
      escaped_term=$(printf '%s' "$prev_term" | sed 's/"/\\"/g')
      escaped_files=$(printf '%s' "$prev_files" | sed 's/"/\\"/g')
      DUPLICATIONS="$DUPLICATIONS
    {\"term\": \"$escaped_term\", \"files\": \"$escaped_files\"}"
      DUP_COUNT=$((DUP_COUNT + 1))
      ;;
  esac
fi

# Check if README.md has an authority source table
HAS_AUTHORITY_TABLE=false
if [ -f README.md ]; then
  if grep -qiE '(authority|authoritative|权威).*(source|源|table|表)' README.md 2>/dev/null; then
    HAS_AUTHORITY_TABLE=true
  fi
fi

cat <<EOF
{
  "project": "$(basename "$(pwd)")",
  "duplications": [$DUPLICATIONS
  ],
  "count": $DUP_COUNT,
  "has_authority_table": $HAS_AUTHORITY_TABLE
}
EOF
