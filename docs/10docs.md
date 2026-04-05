# DOCS Mode — Automated Document Governance

One command, one confirmation, full execution.

Pipeline: **SCAN → UPDATE → ORGANIZE → EXECUTE → VERIFY**

## Trigger

`/10docs` — runs the full pipeline (default).

Variants:
- `/10docs audit` — report only, no changes
- `/10docs sync` — push to Obsidian vault only

---

## Pipeline Overview

| Phase | What | User involvement |
|-------|------|-----------------|
| SCAN | Run 4 detection scripts, collect raw data | None |
| UPDATE | Fix broken pointers, document undocumented dirs, fix stale refs, create missing docs | **None — auto-executes** |
| ORGANIZE | Classify: DELETE / TOC / ARCHIVE / EXTRACT | None |
| PRESENT | Show consolidated report with all planned actions | **Single confirmation** |
| EXECUTE | Apply all cleanup actions | None |
| VERIFY | Re-run audit, show before→after | None |

Key distinction: **UPDATE runs without confirmation** (these are corrections to make docs match reality). **ORGANIZE actions need one confirmation** (these are preferences about structure).

---

## Phase 1: SCAN

Run all scripts silently. Collect raw data.

1. `bin/doc-health-audit.sh` — state files + governance metrics (CLAUDE.md lines, duplicates, TOC coverage, archive leaks)
2. `bin/doc-drift-check.sh` — documentation drift from codebase:
   - Broken pointers (links to non-existent files)
   - Undocumented source directories
   - Stale CLAUDE.md file references
   - README version drift vs package.json
   - Missing standard docs (e.g., ARCHITECTURE.md for large projects)
   - Code directories changed recently without doc updates
3. `bin/doc-soot-check.sh` — cross-file duplicate definitions
4. `bin/doc-toc-gen.sh --check-only` — TOC status for every .md file

---

## Phase 2: UPDATE

**Fix documentation drift BEFORE cleanup.** These are factual corrections — no confirmation needed.

| Drift type | Detection | Fix |
|-----------|-----------|-----|
| Broken pointers | `broken_pointers[]` | Update link, remove dead link, or create missing target |
| Undocumented dirs | `undocumented_dirs` | Add section to ARCHITECTURE.md or README.md |
| Stale CLAUDE.md refs | `stale_claude_refs[]` | Update path or remove reference |
| Version drift | `readme_version_drift` | Update README version to match package.json |
| Missing docs | `missing_docs` | Create doc with content derived from codebase |
| Stale docs | `stale_doc_dirs` | Read recent code changes, update relevant docs |

The agent reads the actual code/files to generate correct documentation content — not placeholder text.

---

## Phase 3: ORGANIZE

After UPDATE, docs are accurate. Now classify structural findings:

### DELETE — Remove duplicate content

For content in CLAUDE.md also in an L2 file:
- Delete from CLAUDE.md, replace with `> See {file}`

For SOOT duplicates across L2 files:
- Keep in authority file, delete from others
- Hierarchy: `docs/state-files.md` > `docs/{domain}.md` > `README.md` > `CLAUDE.md`

### TOC — Add table of contents

Files >200 lines without `## 目录`:
- Generate via `bin/doc-toc-gen.sh` and insert after frontmatter

### ARCHIVE — Move stale content

- Sprint/one-time docs → `docs/archive/`
- CLAUDE.md completed phase sections → compress to 1-line status
- Stale completed tasks in todo.md → archive

### EXTRACT — Split and index

CLAUDE.md blocks that are NOT duplicated, NOT essential for AI context, AND >10 lines:
- Create `docs/{topic}.md` with the content
- Replace block with `> Details: [topic](docs/{topic}.md)`

---

## Phase 4: PRESENT

Single consolidated report showing UPDATE results + ORGANIZE plan:

```
/10docs — DOCUMENT GOVERNANCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Project: {name} | CLAUDE.md: {N} lines (target: <100)

UPDATED ({N} actions applied):
  ✏️ {what was fixed}

DELETE ({N} actions):
  ✂ {what will be deleted}

TOC ({N} files):
  📑 {file} ({N} lines)

ARCHIVE ({N} items):
  📦 {what will be archived}

EXTRACT ({N} blocks):
  📤 {what will be extracted}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
After: CLAUDE.md ≈ {N} lines | AI Friendliness: {score}/5
Apply cleanup? [Y/n]
```

---

## Phase 5: EXECUTE

On confirmation, apply in order:
1. DELETE → remove duplicates, add pointers
2. EXTRACT → split to new files, add index
3. TOC → generate and insert
4. ARCHIVE → git mv, compress

---

## Phase 6: VERIFY

Re-run `bin/doc-health-audit.sh`. Output before→after:

```
DONE: {N}/{M} actions
Before → After:
  CLAUDE.md: {N} → {N} lines
  AI Friendliness: {N}/5 → {N}/5
```

---

## AI Friendliness Score (0-5)

1. CLAUDE.md < 100 lines
2. 0 duplicate lines between L1 and L2
3. All files >200 lines have TOC
4. No archived content referenced in CLAUDE.md
5. CLAUDE.md alone tells AI what to do next (agent judgment)

---

## Vault Sync (`/10docs sync`)

Push project state to Obsidian vault:
1. Read `.10dev/doc-sync.yaml` (auto-create with defaults if missing)
2. `bin/doc-sync.sh sync` — inject YAML frontmatter, write to vault
3. `bin/doc-sync.sh index` — regenerate reading order

---

## Design Principles

1. **Update before organize** — docs must be accurate before restructuring
2. **Corrections auto-execute** — broken links and stale refs are bugs, not preferences
3. **One confirmation for cleanup** — DELETE/TOC/ARCHIVE/EXTRACT presented together
4. **200-line TOC threshold** — files >200 lines get `## 目录`
5. **Archive over delete** — non-essential content preserved in archive
6. **Extract and index** — long blocks become standalone docs with pointer
7. **Authority hierarchy** — `docs/state-files.md` > `docs/{domain}.md` > `README.md` > `CLAUDE.md`
