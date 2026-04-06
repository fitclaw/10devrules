#!/usr/bin/env bash
# doc-drift-check.sh — Detect documentation drift from codebase reality
# Finds: stale references, undocumented code areas, missing docs, broken pointers.
# Usage: doc-drift-check.sh [project_root]
# Output: JSON with categorized drift issues.
set -euo pipefail

PROJECT_ROOT="${1:-.}"
cd "$PROJECT_ROOT"

# --- 1. Broken doc pointers: links in .md files pointing to non-existent files ---
BROKEN_POINTERS=""
BROKEN_COUNT=0
TMPBROKEN="/tmp/doc-drift-broken.$$"
: > "$TMPBROKEN"

for md in *.md docs/*.md; do
  [ -f "$md" ] || continue
  mddir=$(dirname "$md")
  # Extract markdown link targets, filter out URLs and anchors
  grep -oE '\]\([^)]+\)' "$md" 2>/dev/null \
    | sed 's/^\](//' | sed 's/)$//' \
    | grep -vE '^(https?://|mailto:|#)' \
    | grep -vF '{' \
    | sed 's/#.*//' \
    | while IFS= read -r path; do
        [ -z "$path" ] && continue
        if [ ! -e "$mddir/$path" ] && [ ! -e "$path" ]; then
          printf '%s\t%s\n' "$md" "$path" >> "$TMPBROKEN"
        fi
      done || true
done

BROKEN_COUNT=$(wc -l < "$TMPBROKEN" | tr -d '[:space:]')
BROKEN_POINTERS=""
while IFS=$'\t' read -r src link; do
  [ -z "$src" ] && continue
  escaped_src=$(printf '%s' "$src" | sed 's/"/\\"/g')
  escaped_link=$(printf '%s' "$link" | sed 's/"/\\"/g')
  BROKEN_POINTERS="${BROKEN_POINTERS}${BROKEN_POINTERS:+,}{\"file\":\"$escaped_src\",\"link\":\"$escaped_link\"}"
done < "$TMPBROKEN"
rm -f "$TMPBROKEN"

# --- 2. Undocumented source directories ---
# Find top-level source dirs (src/, lib/, app/, components/, pages/, etc.)
# that are not mentioned in any .md file
UNDOCUMENTED_DIRS=""
UNDOC_DIR_COUNT=0

for dir in src lib app components pages api routes services utils hooks models types schema prisma; do
  if [ -d "$dir" ]; then
    mentioned=false
    for md in *.md docs/*.md; do
      [ -f "$md" ] || continue
      if grep -qiF "$dir/" "$md" 2>/dev/null || grep -qiF "$dir" "$md" 2>/dev/null; then
        mentioned=true
        break
      fi
    done
    if [ "$mentioned" = false ]; then
      UNDOCUMENTED_DIRS="${UNDOCUMENTED_DIRS}${UNDOCUMENTED_DIRS:+, }$dir/"
      UNDOC_DIR_COUNT=$((UNDOC_DIR_COUNT + 1))
    fi
  fi
done

# --- 3. CLAUDE.md stale file references ---
# Check if files/paths mentioned in CLAUDE.md actually exist
STALE_REFS=""
STALE_REF_COUNT=0

if [ -f CLAUDE.md ]; then
  # Extract paths that look like file references (word/word.ext or word/word/)
  grep -oE '[a-zA-Z0-9_.-]+/[a-zA-Z0-9_./-]+' CLAUDE.md 2>/dev/null | sort -u | while IFS= read -r ref; do
    # Skip URLs, common non-file patterns
    case "$ref" in
      http*|https*|npm/*|node_modules/*|.git/*|*.com/*|*//*) continue ;;
    esac
    if [ ! -e "$ref" ]; then
      echo "$ref"
    fi
  done > /tmp/doc-drift-stale.$$ 2>/dev/null || true

  STALE_REF_COUNT=$(wc -l < /tmp/doc-drift-stale.$$ | tr -d '[:space:]')
  STALE_REFS=$(paste -sd',' /tmp/doc-drift-stale.$$ 2>/dev/null | sed 's/,/", "/g')
  [ -n "$STALE_REFS" ] && STALE_REFS="\"$STALE_REFS\""
  rm -f /tmp/doc-drift-stale.$$
fi

# --- 4. README.md freshness ---
# Check if README mentions package.json version, and if it matches
README_VERSION_DRIFT=false
if [ -f README.md ] && [ -f package.json ]; then
  PKG_VER=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' package.json 2>/dev/null | head -1 | grep -o '"[^"]*"$' | tr -d '"') || true
  if [ -n "$PKG_VER" ]; then
    if grep -qE 'v?[0-9]+\.[0-9]+\.[0-9]+' README.md 2>/dev/null; then
      if ! grep -qF "$PKG_VER" README.md 2>/dev/null; then
        README_VERSION_DRIFT=true
      fi
    fi
  fi
fi

# --- 5. Missing standard docs ---
# Check for expected docs that don't exist
MISSING_DOCS=""
MISSING_COUNT=0

# If project has src/ or app/, expect some architecture doc
if [ -d src ] || [ -d app ]; then
  has_arch=false
  for f in ARCHITECTURE.md docs/ARCHITECTURE.md docs/architecture.md; do
    [ -f "$f" ] && has_arch=true && break
  done
  if [ "$has_arch" = false ]; then
    _find_dirs=""
    [ -d src ] && _find_dirs="$_find_dirs src"
    [ -d app ] && _find_dirs="$_find_dirs app"
    file_count=0
    if [ -n "$_find_dirs" ]; then
      file_count=$(find $_find_dirs -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.go' 2>/dev/null | wc -l | tr -d '[:space:]')
    fi
    if [ "${file_count:-0}" -gt 10 ]; then
      MISSING_DOCS="${MISSING_DOCS}${MISSING_DOCS:+, }ARCHITECTURE.md (${file_count}+ source files)"
      MISSING_COUNT=$((MISSING_COUNT + 1))
    fi
  fi
fi

# If project has CLAUDE.md but no docs/ directory
if [ -f CLAUDE.md ] && [ ! -d docs ]; then
  MISSING_DOCS="${MISSING_DOCS}${MISSING_DOCS:+, }docs/ directory"
  MISSING_COUNT=$((MISSING_COUNT + 1))
fi

# --- 6. Recently changed code without doc updates ---
# Files changed in last 7 days: compare source vs doc modification times
STALE_DOCS=""
STALE_DOC_COUNT=0

if command -v git >/dev/null 2>&1 && git rev-parse --git-dir >/dev/null 2>&1; then
  # Get docs that haven't been modified in the last 30 commits but code has
  recent_code_dirs=$(git log --oneline -30 --name-only --diff-filter=M 2>/dev/null | grep -E '\.(ts|js|py|go|rs|java|swift|kt|tsx|jsx)$' | sed 's|/[^/]*$||' | sort -u | head -20) || true
  for cdir in $recent_code_dirs; do
    [ -z "$cdir" ] && continue
    # Check if any doc mentions this directory
    doc_mentions=false
    for md in *.md docs/*.md; do
      [ -f "$md" ] || continue
      if grep -qF "$cdir" "$md" 2>/dev/null; then
        # Check if doc was also recently modified
        doc_in_recent=$(git log --oneline -30 --name-only 2>/dev/null | grep -F "$md" | head -1) || true
        if [ -n "$doc_in_recent" ]; then
          doc_mentions=true
          break
        fi
      fi
    done
    if [ "$doc_mentions" = false ] && [ -d "$cdir" ]; then
      STALE_DOCS="${STALE_DOCS}${STALE_DOCS:+, }$cdir"
      STALE_DOC_COUNT=$((STALE_DOC_COUNT + 1))
    fi
  done
fi

# --- Output ---
cat <<EOF
{
  "project": "$(basename "$(pwd)")",
  "broken_pointers": [$BROKEN_POINTERS],
  "broken_pointer_count": $BROKEN_COUNT,
  "undocumented_dirs": "$UNDOCUMENTED_DIRS",
  "undocumented_dir_count": $UNDOC_DIR_COUNT,
  "stale_claude_refs": [$STALE_REFS],
  "stale_claude_ref_count": $STALE_REF_COUNT,
  "readme_version_drift": $README_VERSION_DRIFT,
  "missing_docs": "$MISSING_DOCS",
  "missing_doc_count": $MISSING_COUNT,
  "stale_doc_dirs": "$STALE_DOCS",
  "stale_doc_dir_count": $STALE_DOC_COUNT
}
EOF
