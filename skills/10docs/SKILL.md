---
name: 10docs
preamble-tier: 2
description: |
  DOCS mode for 10 Development Rules. Automated document governance pipeline —
  first updates missing/stale docs, then cleans up duplicates, generates TOCs,
  archives stale content, extracts and indexes. One command, one confirmation.
  Use when asked to "sync docs", "doc health", "clean up docs", "archive phase",
  "slim CLAUDE.md", "organize docs", "update docs", "AI friendliness", or "what's stale".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
  - WebSearch
hooks:
  PreToolUse:
    - matcher: "Edit"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/../../bin/check-boundary.sh"
          statusMessage: "Rule 1: Checking scope boundary..."
    - matcher: "Write"
      hooks:
        - type: command
          command: "bash ${CLAUDE_SKILL_DIR}/../../bin/check-boundary.sh"
          statusMessage: "Rule 1: Checking scope boundary..."
---

# 10docs — Automated Document Governance

One command. One confirmation. Full execution.

Pipeline: **SCAN → UPDATE → ORGANIZE → EXECUTE → VERIFY**

## Preamble (run first)

```bash
# Locate 10dev project root
source "${CLAUDE_SKILL_DIR}/../../bin/detect-root.sh" 2>/dev/null || {
  _10DEV_ROOT="$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)"
  echo "10DEV_ROOT: ${_10DEV_ROOT}"
}

# --- SCAN — collect all data ---
echo "=== SCAN ==="

# Project state
_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
_HAS_SYNC_CONFIG=$([ -f .10dev/doc-sync.yaml ] && echo "yes" || echo "no")
echo "BRANCH: $_BRANCH | SYNC_CONFIG: $_HAS_SYNC_CONFIG"

# Health audit (state files + governance metrics)
echo "--- health-audit ---"
bash "${_10DEV_ROOT}/bin/doc-health-audit.sh" . 7

# Drift check (broken pointers, undocumented dirs, stale refs, missing docs)
echo "--- drift-check ---"
bash "${_10DEV_ROOT}/bin/doc-drift-check.sh" .

# SOOT check (cross-file duplicates)
echo "--- soot-check ---"
bash "${_10DEV_ROOT}/bin/doc-soot-check.sh" .

# File inventory with line counts and TOC status
echo "--- file-inventory ---"
for f in *.md docs/*.md; do
  [ -f "$f" ] || continue
  bash "${_10DEV_ROOT}/bin/doc-toc-gen.sh" "$f" --check-only
done

# CLAUDE.md size
echo "--- claude-md ---"
[ -f CLAUDE.md ] && wc -l CLAUDE.md
```

## Procedure — MANDATORY STEPS

**DO NOT** read the router SKILL.md or other files. Everything you need is here. Execute these steps IN ORDER.

### Step 1: READ all docs

From scan results, identify every `.md` file in the project. **Read them ALL** — CLAUDE.md, README.md, docs/*.md. You need the full picture before making any changes.

### Step 2: UPDATE — Fix documentation drift FIRST

Before any cleanup, ensure docs are accurate and complete. Use the drift-check output.

**2a. Fix broken pointers** — For each `broken_pointers` entry: the link target doesn't exist. Either:
- Update the link to point to the correct file (if it was renamed/moved)
- Remove the link if the target was deleted
- Create the missing doc if it should exist

**2b. Document undocumented directories** — For each `undocumented_dirs`: a source directory exists but no doc mentions it. Add a section to the appropriate doc (ARCHITECTURE.md, README.md, or CLAUDE.md) describing what this directory contains.

**2c. Fix stale CLAUDE.md references** — For each `stale_claude_refs`: a file path in CLAUDE.md doesn't exist anymore. Update or remove the reference.

**2d. Fix version drift** — If `readme_version_drift` is true: README.md mentions an old version. Update it to match package.json.

**2e. Create missing docs** — For each `missing_docs` entry: a standard doc is expected but doesn't exist. Create it with appropriate content based on the codebase.

**2f. Update stale docs for changed code** — For each `stale_doc_dirs`: code in this directory changed recently but related docs didn't. Read the code changes and update the relevant docs.

Execute all UPDATE actions immediately — no confirmation needed. These are corrections, not preferences.

### Step 3: ORGANIZE — Build the cleanup plan

Now that docs are accurate, classify findings into four categories:

**DELETE** — Content in CLAUDE.md that also exists in an L2 file.
- Delete from CLAUDE.md, replace with `> See {L2 file}`
- For SOOT duplicates across L2 files: keep in authority, delete from others
- Authority: `docs/state-files.md` > `docs/{domain}.md` > `README.md` > `CLAUDE.md`

**TOC** — Files >200 lines without `## 目录` (from file-inventory).
- Generate and insert after frontmatter

**ARCHIVE** — Stale/one-time content.
- Files: `*-plan.md`, `*-sprint*.md`, `*-checklist.md`, `*-recovery*.md`
- CLAUDE.md completed phase sections → compress to 1-line
- Stale completed tasks in todo.md

**EXTRACT** — CLAUDE.md blocks that are NOT duplicated, NOT essential for AI context, AND >10 lines.
- Create `docs/{topic}.md`, replace with `> Details: [topic](docs/{topic}.md)`

### Step 4: Present ONE consolidated report

Output this EXACT format:

```
/10docs — DOCUMENT GOVERNANCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project: {name} | CLAUDE.md: {N} lines (target: <100)

UPDATED ({N} actions):
  ✏️ {description of each update action taken in Step 2}

DELETE ({N} actions):
  ✂ {description of each delete action}

TOC ({N} files):
  📑 {file} ({N} lines) — insert ## 目录

ARCHIVE ({N} items):
  📦 {description of each archive action}

EXTRACT ({N} blocks):
  📤 {description of each extract action}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
After: CLAUDE.md ≈ {N} lines | AI Friendliness: {score}/5
Apply cleanup? [Y/n]
```

UPDATED section shows what was already done (Step 2). The remaining sections need confirmation.
If a category has 0 actions, show `(0 actions)` — do not skip.

### Step 5: Execute cleanup on confirmation

On `Y` or user proceeds, execute in order:
1. DELETE — remove duplicates, add pointers
2. EXTRACT — split to new files, add index entries
3. TOC — generate and insert (including newly created files)
4. ARCHIVE — git mv files, compress CLAUDE.md sections

### Step 6: Verify

Run `bin/doc-health-audit.sh` again. Output:

```
DONE: {N}/{M} actions applied
Before → After:
  CLAUDE.md: {N} → {N} lines
  AI Friendliness: {N}/5 → {N}/5
```

---

## Variant: `/10docs audit`

Steps 1-4 only. Show report, do NOT execute. End with "Run `/10docs` to apply."

## Variant: `/10docs sync`

Skip pipeline. Push to Obsidian vault via `bin/doc-sync.sh`.
