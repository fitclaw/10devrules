# DOCS Mode — Document Health & Obsidian Sync

Manage document health, phase-aware cleanup, and Obsidian vault synchronization for cross-version memory.

## Sub-Commands

| Signal | Sub-Command |
|--------|-------------|
| `/10docs`, `/10docs audit`, "doc health", "what's stale" | **AUDIT** |
| `/10docs cleanup`, "clean up docs", "archive phase" | **CLEANUP** |
| `/10docs sync`, "sync to vault", "push to vault" | **SYNC** |
| `/10docs snapshot`, "record decision" | **SNAPSHOT** |
| `/10docs index`, "rebuild index" | **INDEX** |

Default (no sub-command): **AUDIT**.

---

## First Run Setup

If `.10dev/doc-sync.yaml` does not exist, ask:

```
Doc-sync needs a configuration. Choose setup:

A) Default config (vault: ~/dev-vault, threshold: 7 days) — recommended
B) Custom config — specify vault path and parameters
C) Skip vault — only do project-local doc cleanup
```

Create `.10dev/doc-sync.yaml`:

```yaml
vault_root: ~/dev-vault
project_name: auto
staleness_threshold_days: 7
auto_archive_on_phase_complete: false
sync_on_mode_transition: true
```

---

## AUDIT

Detect stale, conflicting, and orphaned documents.

1. Run `bin/doc-health-audit.sh` from the project root.
2. Present the health report:

```
DOC-SYNC: HEALTH AUDIT
━━━━━━━━━━━━━━━━━━━━━━
Project: {name} | Phase: {detected}

todo.md:      {N} stale tasks (completed >{threshold}d ago)
lessons.md:   {N} untagged entries / {N} total
contract.md:  {N} drifted interfaces
boundary.txt: {N} out-of-scope edits
orphaned:     {list}
━━━━━━━━━━━━━━━━━━━━━━
Health: GREEN | YELLOW | RED
Recommendation: {action}
```

Health logic:
- All zero -> **GREEN**
- Stale tasks or untagged lessons -> **YELLOW**
- Contract drift or boundary violations -> **RED**

---

## CLEANUP

Phase-aware archival and document reorganization.

1. Detect current phase from `todo.md` state:
   - All unchecked -> PLAN
   - Mix of checked/unchecked -> EXECUTE
   - All checked -> REVIEW or DISTILL
2. If phase transition detected, offer archive:

```
Phase "{PHASE}" appears complete. Archive?

A) Archive — snapshot current docs, start fresh for next phase
B) Not yet — still working in this phase
C) Show me what would be archived first
```

3. On archive:
   - Create `.10dev/archive/{PHASE}-{YYYY-MM-DD}/`
   - Copy `todo.md`, `boundary.txt`, `contract.md`, `lessons.md` to archive
   - Strip completed items from `todo.md`
   - Append `## Phase Complete: {PHASE}` header in `lessons.md`
4. Reorganize `lessons.md` entries under topic headers:
   - Scoping (R1), Contracts (R2), Dependencies (R3), Staging (R4)
   - Isolation (R5), Review (R6), Failure Paths (R7), Docs (R8)
   - Verification (R9), Principles (R10)

---

## SYNC

Push project state to Obsidian vault with YAML frontmatter.

1. Read `.10dev/doc-sync.yaml` for vault path and project name.
2. Derive project name: `auto` uses `basename $(git rev-parse --show-toplevel)`.
3. Run `bin/doc-sync.sh` which:
   - Creates vault directory structure if needed:
     ```
     {vault}/projects/{project}/active/
     {vault}/projects/{project}/archive/
     {vault}/projects/{project}/decisions/
     {vault}/projects/{project}/lessons/
     ```
   - For each state file, injects YAML frontmatter and writes to `active/`:
     ```yaml
     ---
     title: "{file} — {project}"
     status: active
     tags: [{project}, {phase}, doc-sync, 10dev]
     phase: {current phase}
     synced: {ISO timestamp}
     source: {relative path}
     ---
     ```
   - Generates `_index.md` with phase-aware reading order.
   - Updates `_health.md` with latest audit results.

---

## SNAPSHOT

Create a versioned decision record (ADR).

1. Count existing files in `{vault}/projects/{project}/decisions/` for auto-numbering.
2. Create `{NNN}-{slug}.md`:

```markdown
---
title: "ADR-{NNN}: {decision title}"
status: accepted
tags: [decision, {project}, {phase}]
date: {ISO date}
---

# ADR-{NNN}: {decision title}

## Context
{extracted from boundary.txt and contract.md}

## Decision
{what was decided}

## Consequences
{extracted from lessons.md entries near this date}
```

---

## INDEX

Rebuild the vault reading order.

1. Scan `{vault}/projects/{project}/` for all `.md` files.
2. Generate `_index.md`:

```markdown
---
title: "{project} — Dev Memory Index"
status: active
tags: [index, {project}, doc-sync]
---

# {project} — Reading Order

> Phase: {current phase} | Last synced: {timestamp}

## Active (read first)
- [todo](active/todo.md) — current task state
- [boundary](active/boundary.md) — scope lock
- [contract](active/contract.md) — frozen interfaces
- [lessons](active/lessons.md) — error prevention

## Decisions (read on demand)
{numbered list of ADRs, newest first}

## Archive (history only)
{grouped by phase-date, newest first}
```
