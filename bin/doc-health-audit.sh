#!/usr/bin/env bash
# doc-health-audit.sh — Document health check for ten-dev-rules DOCS mode
# Scans project state files for staleness, untagged entries, and orphans.
# Output: JSON with counts for each category.
set -euo pipefail

PROJECT_ROOT="${1:-.}"
THRESHOLD_DAYS="${2:-7}"

cd "$PROJECT_ROOT"

# --- todo.md: count stale completed tasks ---
STALE_TASKS=0
TODO_TOTAL=0
if [ -f todo.md ]; then
  TODO_TOTAL=$(grep -c '^\- \[' todo.md 2>/dev/null || true)
  TODO_TOTAL=$(echo "$TODO_TOTAL" | tr -d '[:space:]')
  TODO_TOTAL=${TODO_TOTAL:-0}
  DONE_COUNT=$(grep -c '^\- \[x\]' todo.md 2>/dev/null || true)
  DONE_COUNT=$(echo "$DONE_COUNT" | tr -d '[:space:]')
  DONE_COUNT=${DONE_COUNT:-0}
  if [ "$DONE_COUNT" -gt 0 ]; then
    # Check file modification time — if todo.md hasn't been touched in threshold days, completed tasks are stale
    if [ "$(uname)" = "Darwin" ]; then
      LAST_MOD=$(stat -f %m todo.md 2>/dev/null || echo "0")
    else
      LAST_MOD=$(stat -c %Y todo.md 2>/dev/null || echo "0")
    fi
    NOW=$(date +%s)
    AGE_DAYS=$(( (NOW - LAST_MOD) / 86400 ))
    if [ "$AGE_DAYS" -ge "$THRESHOLD_DAYS" ]; then
      STALE_TASKS="$DONE_COUNT"
    fi
  fi
fi

# --- lessons.md: count untagged entries ---
UNTAGGED_LESSONS=0
LESSONS_TOTAL=0
if [ -f lessons.md ]; then
  # Count lines starting with "- " or "* " as entries
  LESSONS_TOTAL=$(grep -cE '^\s*[-*] ' lessons.md 2>/dev/null || true)
  LESSONS_TOTAL=$(echo "$LESSONS_TOTAL" | tr -d '[:space:]')
  LESSONS_TOTAL=${LESSONS_TOTAL:-0}
  # Untagged = entries without R1-R10 or topic tags like [scoping], [contract], etc.
  TAGGED=$(grep -cE '^\s*[-*] .*(\[R[0-9]+\]|\[scoping\]|\[contract\]|\[dependency\]|\[staging\]|\[isolation\]|\[review\]|\[failure\]|\[docs\]|\[verification\]|\[distill\])' lessons.md 2>/dev/null || true)
  TAGGED=$(echo "$TAGGED" | tr -d '[:space:]')
  TAGGED=${TAGGED:-0}
  UNTAGGED_LESSONS=$(( LESSONS_TOTAL - TAGGED ))
  if [ "$UNTAGGED_LESSONS" -lt 0 ]; then
    UNTAGGED_LESSONS=0
  fi
fi

# --- contract.md: check existence and basic staleness ---
CONTRACT_DRIFT=0
if [ -f .10dev/contract.md ]; then
  # Simple heuristic: if contract mentions types/interfaces, grep codebase for them
  # Count interfaces mentioned in contract that can't be found in source
  INTERFACES=$(grep -oE '(interface|type|class|schema)\s+[A-Z][A-Za-z0-9]+' .10dev/contract.md 2>/dev/null | awk '{print $2}' | sort -u)
  for iface in $INTERFACES; do
    FOUND=$(grep -rl "$iface" --include='*.ts' --include='*.js' --include='*.py' --include='*.go' --include='*.rs' --include='*.java' --include='*.swift' --include='*.kt' . 2>/dev/null | grep -v node_modules | grep -v .10dev | head -1)
    if [ -z "$FOUND" ]; then
      CONTRACT_DRIFT=$((CONTRACT_DRIFT + 1))
    fi
  done
fi

# --- boundary.txt: check for out-of-scope edits ---
BOUNDARY_VIOLATIONS=0
if [ -f .10dev/boundary.txt ]; then
  # Get recently modified files (last 7 days) and check against boundary
  while IFS= read -r recent_file; do
    IN_SCOPE=false
    while IFS= read -r allowed; do
      allowed=$(printf '%s' "$allowed" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      [ -z "$allowed" ] && continue
      [[ "$allowed" == \#* ]] && continue
      if [ "$recent_file" = "$allowed" ] || case "$recent_file" in "${allowed}/"*) true;; *) false;; esac; then
        IN_SCOPE=true; break
      fi
    done < .10dev/boundary.txt
    if [ "$IN_SCOPE" = false ]; then
      BOUNDARY_VIOLATIONS=$((BOUNDARY_VIOLATIONS + 1))
    fi
  done < <(find . -name '*.md' -o -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.go' | grep -v node_modules | grep -v .git | grep -v .10dev)
fi

# --- orphaned docs: .md files not in todo.md or any index ---
ORPHANED=""
for md in *.md; do
  [ "$md" = "*.md" ] && break
  case "$md" in
    todo.md|lessons.md|README.md|README.zh-CN.md|CONTRIBUTING.md|SECURITY.md|CODE_OF_CONDUCT.md|CHANGELOG.md|CLAUDE.md|SKILL.md|TODOS.md|LICENSE.md|VERSION.md) continue ;;
  esac
  ORPHANED="${ORPHANED}${ORPHANED:+, }$md"
done

# --- CLAUDE.md line count ---
CLAUDE_MD_LINES=0
if [ -f CLAUDE.md ]; then
  CLAUDE_MD_LINES=$(wc -l < CLAUDE.md | tr -d '[:space:]')
fi

# --- CLAUDE.md duplication with docs/ ---
CLAUDE_MD_DUPLICATED=0
if [ -f CLAUDE.md ] && [ -d docs ]; then
  while IFS= read -r line; do
    trimmed=$(printf '%s' "$line" | sed 's/^[[:space:]]*//')
    # Skip headings, empty lines, short lines, frontmatter markers, and bullet-only lines
    [ -z "$trimmed" ] && continue
    [ "${#trimmed}" -le 20 ] && continue
    case "$trimmed" in
      '#'*|'---'|'```'*|'>'*|'|'*) continue ;;
    esac
    # Search in docs/ for this exact line
    if grep -qrF "$trimmed" docs/ 2>/dev/null; then
      CLAUDE_MD_DUPLICATED=$((CLAUDE_MD_DUPLICATED + 1))
    fi
  done < CLAUDE.md
fi

# --- Large files missing TOC ---
LARGE_FILES_MISSING_TOC=""
LARGE_MISSING_COUNT=0
for md_file in *.md docs/*.md; do
  [ -f "$md_file" ] || continue
  line_count=$(wc -l < "$md_file" | tr -d '[:space:]')
  if [ "$line_count" -gt 200 ]; then
    has_toc=$(head -30 "$md_file" | grep -cE '^## (目录|Table of Contents)' 2>/dev/null || true)
    has_toc=$(echo "$has_toc" | tr -d '[:space:]')
    if [ "${has_toc:-0}" -eq 0 ]; then
      LARGE_FILES_MISSING_TOC="${LARGE_FILES_MISSING_TOC}${LARGE_FILES_MISSING_TOC:+, }$md_file"
      LARGE_MISSING_COUNT=$((LARGE_MISSING_COUNT + 1))
    fi
  fi
done

# --- Archive leaks in CLAUDE.md ---
ARCHIVE_LEAKS=0
if [ -f CLAUDE.md ] && [ -d docs/archive ]; then
  for archived in docs/archive/*; do
    [ -e "$archived" ] || continue
    aname=$(basename "$archived")
    if grep -qF "$aname" CLAUDE.md 2>/dev/null; then
      ARCHIVE_LEAKS=$((ARCHIVE_LEAKS + 1))
    fi
  done
fi

# --- Determine health level ---
HEALTH="GREEN"
RECOMMENDATION="All documents are healthy."

if [ "$STALE_TASKS" -gt 0 ] || [ "$UNTAGGED_LESSONS" -gt 3 ]; then
  HEALTH="YELLOW"
  RECOMMENDATION="Run /10docs cleanup to archive stale tasks and tag lessons."
fi

if [ "$CLAUDE_MD_LINES" -gt 100 ] || [ "$CLAUDE_MD_DUPLICATED" -gt 0 ] || [ "$LARGE_MISSING_COUNT" -gt 0 ] || [ "$ARCHIVE_LEAKS" -gt 0 ]; then
  if [ "$HEALTH" = "GREEN" ]; then
    HEALTH="YELLOW"
    RECOMMENDATION="Documentation governance issues detected. Run /10docs to auto-fix."
  fi
fi

if [ "$CONTRACT_DRIFT" -gt 0 ] || [ "$BOUNDARY_VIOLATIONS" -gt 5 ]; then
  HEALTH="RED"
  RECOMMENDATION="Contract drift or boundary violations detected. Run /10docs cleanup and /10review."
fi

# --- Output JSON ---
cat <<EOF
{
  "project": "$(basename "$(pwd)")",
  "todo_stale": $STALE_TASKS,
  "todo_total": $TODO_TOTAL,
  "lessons_untagged": $UNTAGGED_LESSONS,
  "lessons_total": $LESSONS_TOTAL,
  "contract_drift": $CONTRACT_DRIFT,
  "boundary_violations": $BOUNDARY_VIOLATIONS,
  "orphaned": "$ORPHANED",
  "claude_md_lines": $CLAUDE_MD_LINES,
  "claude_md_duplicated_lines": $CLAUDE_MD_DUPLICATED,
  "large_files_missing_toc": "$LARGE_FILES_MISSING_TOC",
  "large_files_missing_toc_count": $LARGE_MISSING_COUNT,
  "archive_leaks_in_claude_md": $ARCHIVE_LEAKS,
  "health": "$HEALTH",
  "recommendation": "$RECOMMENDATION"
}
EOF
