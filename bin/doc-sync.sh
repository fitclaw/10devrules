#!/usr/bin/env bash
# doc-sync.sh — Obsidian vault sync engine for ten-dev-rules DOCS mode
# Syncs project state files to an Obsidian vault with YAML frontmatter.
# Usage: doc-sync.sh <action> [options]
#   Actions: init, sync, archive, index
set -euo pipefail

ACTION="${1:-sync}"
PROJECT_ROOT="${2:-.}"
CONFIG_FILE="$PROJECT_ROOT/.10dev/doc-sync.yaml"

# --- Read config ---
VAULT_ROOT="$HOME/dev-vault"
PROJECT_NAME=""

if [ -f "$CONFIG_FILE" ]; then
  VAULT_ROOT=$(grep '^vault_root:' "$CONFIG_FILE" | sed 's/^vault_root:[[:space:]]*//' | sed "s|~|$HOME|")
  PROJECT_NAME=$(grep '^project_name:' "$CONFIG_FILE" | sed 's/^project_name:[[:space:]]*//')
fi

if [ -z "$PROJECT_NAME" ] || [ "$PROJECT_NAME" = "auto" ]; then
  PROJECT_NAME=$(cd "$PROJECT_ROOT" && basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || basename "$(cd "$PROJECT_ROOT" && pwd)")
fi

VAULT_PROJECT="$VAULT_ROOT/projects/$PROJECT_NAME"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_STAMP=$(date +"%Y-%m-%d")

# --- Detect current phase ---
detect_phase() {
  local phase="UNKNOWN"
  if [ -f "$PROJECT_ROOT/todo.md" ]; then
    local done_count=$(grep -c '^\- \[x\]' "$PROJECT_ROOT/todo.md" 2>/dev/null || echo "0")
    local todo_count=$(grep -c '^\- \[ \]' "$PROJECT_ROOT/todo.md" 2>/dev/null || echo "0")
    if [ "$todo_count" -gt 0 ] && [ "$done_count" -eq 0 ]; then
      phase="PLAN"
    elif [ "$todo_count" -gt 0 ]; then
      phase="EXECUTE"
    elif [ "$todo_count" -eq 0 ] && [ "$done_count" -gt 0 ]; then
      phase="REVIEW"
    fi
  fi
  echo "$phase"
}

# --- Add YAML frontmatter to a file ---
add_frontmatter() {
  local source_file="$1"
  local dest_file="$2"
  local title="$3"
  local phase="$4"

  local basename_file=$(basename "$source_file")

  cat > "$dest_file" <<FRONTMATTER
---
title: "$title"
status: active
tags: [$PROJECT_NAME, $phase, doc-sync, 10dev]
phase: $phase
synced: $TIMESTAMP
source: $basename_file
---

FRONTMATTER

  cat "$source_file" >> "$dest_file"
}

# --- Generate _index.md ---
generate_index() {
  local phase=$(detect_phase)

  cat > "$VAULT_PROJECT/_index.md" <<INDEX
---
title: "$PROJECT_NAME — Dev Memory Index"
status: active
tags: [index, $PROJECT_NAME, doc-sync]
---

# $PROJECT_NAME — Reading Order

> Phase: $phase | Last synced: $TIMESTAMP

## Active (read first)
INDEX

  # List active files
  if [ -d "$VAULT_PROJECT/active" ]; then
    for f in "$VAULT_PROJECT/active/"*.md; do
      [ -f "$f" ] || continue
      local name=$(basename "$f" .md)
      echo "- [$name](active/$(basename "$f"))" >> "$VAULT_PROJECT/_index.md"
    done
  fi

  # List decisions
  if [ -d "$VAULT_PROJECT/decisions" ] && [ "$(ls -A "$VAULT_PROJECT/decisions/" 2>/dev/null)" ]; then
    echo "" >> "$VAULT_PROJECT/_index.md"
    echo "## Decisions (read on demand)" >> "$VAULT_PROJECT/_index.md"
    for f in $(ls -r "$VAULT_PROJECT/decisions/"*.md 2>/dev/null); do
      local name=$(basename "$f" .md)
      echo "- [$name](decisions/$(basename "$f"))" >> "$VAULT_PROJECT/_index.md"
    done
  fi

  # List archives
  if [ -d "$VAULT_PROJECT/archive" ] && [ "$(ls -A "$VAULT_PROJECT/archive/" 2>/dev/null)" ]; then
    echo "" >> "$VAULT_PROJECT/_index.md"
    echo "## Archive (history only)" >> "$VAULT_PROJECT/_index.md"
    for d in $(ls -dr "$VAULT_PROJECT/archive/"*/ 2>/dev/null); do
      local dirname=$(basename "$d")
      echo "- [$dirname](archive/$dirname/)" >> "$VAULT_PROJECT/_index.md"
    done
  fi
}

# === ACTIONS ===

case "$ACTION" in
  init)
    # Create vault directory structure
    mkdir -p "$VAULT_PROJECT/active"
    mkdir -p "$VAULT_PROJECT/archive"
    mkdir -p "$VAULT_PROJECT/decisions"
    mkdir -p "$VAULT_PROJECT/lessons"

    # Create .obsidian if vault root is new
    if [ ! -d "$VAULT_ROOT/.obsidian" ]; then
      mkdir -p "$VAULT_ROOT/.obsidian"
      echo '{}' > "$VAULT_ROOT/.obsidian/app.json"
    fi

    generate_index
    echo "Vault initialized: $VAULT_PROJECT"
    ;;

  sync)
    # Ensure directories exist
    mkdir -p "$VAULT_PROJECT/active"

    local_phase=$(detect_phase)

    # Sync each state file
    for src_pair in \
      "todo.md:todo — $PROJECT_NAME" \
      "lessons.md:lessons — $PROJECT_NAME" \
      ".10dev/boundary.txt:boundary — $PROJECT_NAME" \
      ".10dev/contract.md:contract — $PROJECT_NAME"; do

      local src="${src_pair%%:*}"
      local title="${src_pair#*:}"
      local dest_name=$(basename "$src" | sed 's/\.txt$/.md/')

      if [ -f "$PROJECT_ROOT/$src" ]; then
        add_frontmatter "$PROJECT_ROOT/$src" "$VAULT_PROJECT/active/$dest_name" "$title" "$local_phase"
      fi
    done

    generate_index
    echo "Synced to: $VAULT_PROJECT/active/"
    ;;

  archive)
    local_phase=$(detect_phase)
    ARCHIVE_DIR="$VAULT_PROJECT/archive/${local_phase}-${DATE_STAMP}"
    mkdir -p "$ARCHIVE_DIR"

    # Move active to archive
    if [ -d "$VAULT_PROJECT/active" ]; then
      for f in "$VAULT_PROJECT/active/"*.md; do
        [ -f "$f" ] || continue
        # Update status in frontmatter
        sed 's/^status: active/status: archived/' "$f" > "$ARCHIVE_DIR/$(basename "$f")"
      done
    fi

    # Create snapshot summary
    cat > "$ARCHIVE_DIR/_snapshot.md" <<SNAP
---
title: "Phase Snapshot: $local_phase ($DATE_STAMP)"
status: archived
tags: [snapshot, $PROJECT_NAME, $local_phase]
archived: $TIMESTAMP
---

# Phase Snapshot: $local_phase

Archived on $DATE_STAMP from project $PROJECT_NAME.
SNAP

    # Clear active for fresh start
    rm -f "$VAULT_PROJECT/active/"*.md

    generate_index
    echo "Archived to: $ARCHIVE_DIR"
    ;;

  index)
    generate_index
    echo "Index regenerated: $VAULT_PROJECT/_index.md"
    ;;

  *)
    echo "Usage: doc-sync.sh <init|sync|archive|index> [project_root]"
    exit 1
    ;;
esac
