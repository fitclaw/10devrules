#!/usr/bin/env bash
# doc-toc-gen.sh — TOC generator for ten-dev-rules DOCS mode
# Checks if a markdown file needs a TOC (>300 lines) and generates one.
# Usage: doc-toc-gen.sh <file.md> [--check-only]
# --check-only: output JSON with file, lines, has_toc, needs_toc
# Otherwise:   output a ## 目录 block to stdout (does NOT modify the file)
set -euo pipefail

FILE="${1:-}"
CHECK_ONLY=false

if [ -z "$FILE" ]; then
  echo "Usage: doc-toc-gen.sh <file.md> [--check-only]" >&2
  exit 1
fi

if [ "${2:-}" = "--check-only" ]; then
  CHECK_ONLY=true
fi

if [ ! -f "$FILE" ]; then
  echo "File not found: $FILE" >&2
  exit 1
fi

LINE_COUNT=$(wc -l < "$FILE" | tr -d '[:space:]')

# Check for existing TOC in first 30 lines
HAS_TOC=false
if head -30 "$FILE" | grep -qE '^## (目录|Table of Contents)'; then
  HAS_TOC=true
fi

NEEDS_TOC=false
if [ "$LINE_COUNT" -gt 200 ] && [ "$HAS_TOC" = false ]; then
  NEEDS_TOC=true
fi

if [ "$CHECK_ONLY" = true ]; then
  cat <<EOF
{
  "file": "$FILE",
  "lines": $LINE_COUNT,
  "has_toc": $HAS_TOC,
  "needs_toc": $NEEDS_TOC
}
EOF
  exit 0
fi

# --- Generate TOC ---
echo "## 目录"
echo ""

# Parse ## and ### headings, skip the TOC heading itself and frontmatter
IN_FRONTMATTER=false
IN_CODE_BLOCK=false
FIRST_LINE=true

while IFS= read -r line; do
  # Track frontmatter (--- delimited)
  if [ "$FIRST_LINE" = true ] && [ "$line" = "---" ]; then
    IN_FRONTMATTER=true
    FIRST_LINE=false
    continue
  fi
  FIRST_LINE=false

  if [ "$IN_FRONTMATTER" = true ]; then
    if [ "$line" = "---" ]; then
      IN_FRONTMATTER=false
    fi
    continue
  fi

  # Track code blocks
  case "$line" in
    '```'*)
      if [ "$IN_CODE_BLOCK" = true ]; then
        IN_CODE_BLOCK=false
      else
        IN_CODE_BLOCK=true
      fi
      continue
      ;;
  esac
  [ "$IN_CODE_BLOCK" = true ] && continue

  # Extract ## and ### headings
  case "$line" in
    '## '*)
      heading="${line#\#\# }"
      # Skip TOC heading itself
      case "$heading" in
        "目录"|"Table of Contents") continue ;;
      esac
      # Generate anchor: lowercase, spaces to hyphens, strip non-alnum
      anchor=$(printf '%s' "$heading" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g; s/[^a-z0-9\x80-\xff-]//g')
      echo "- [[#${heading}]]"
      ;;
    '### '*)
      heading="${line#\#\#\# }"
      echo "  - [[#${heading}]]"
      ;;
  esac
done < "$FILE"
