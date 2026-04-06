# Changelog

## v2.5.1 — Bug Fixes

Four bugs found via `/10review` deep code review, all confirmed and fixed:

- **[P1] Boundary guard bypassed on macOS** — `realpath -m` is not available on macOS. Fallback only cleaned duplicate slashes, not `..` traversal. Paths like `src/../secrets/key.txt` passed the check. Fix: portable 3-tier canonicalization (`python3 os.path.normpath` > `realpath -m` > `sed`).
- **[P1] `/10docs` crashed on projects with `src/` or `app/`** — `doc-drift-check.sh` used shell parameter expansion `${src:+src}` instead of literal directory names, causing `find` to error on macOS. Fix: explicit `[ -d src ] && dirs="src"` guard.
- **[P2] Boundary violation false positives** — `find .` outputs `./src/main.ts` but boundary has `src/`, prefix never matched. Also, trailing `/` in boundary caused double-slash `src//`. Fix: strip `./` from find output, strip trailing `/` from allowed paths.
- **[P2] Template placeholders reported as broken links** — `doc-drift-check.sh` treated `docs/{topic}.md` in documentation examples as real file paths. Fix: filter out links containing `{`.

---

## v2.5.0 — Automated Document Governance

`/10docs` rewritten as a fully automated pipeline. One command, one confirmation, full execution.

### New: UPDATE-first pipeline

`/10docs` now runs **SCAN → UPDATE → ORGANIZE → EXECUTE → VERIFY**:

- **UPDATE phase** runs before cleanup — fixes broken links, documents undocumented directories, updates stale references, creates missing docs. These are factual corrections that auto-execute without confirmation.
- **ORGANIZE phase** builds a consolidated plan (DELETE/TOC/ARCHIVE/EXTRACT) presented as one report with one confirmation.

### New scripts

| Script | Purpose |
|--------|---------|
| `bin/doc-drift-check.sh` | Detect documentation drift: broken pointers, undocumented source dirs, stale CLAUDE.md refs, README version drift, missing standard docs, code changed without doc updates |
| `bin/doc-toc-gen.sh` | Check and generate `## 目录` (Table of Contents) for markdown files |
| `bin/doc-soot-check.sh` | Single Source of Truth checker — find duplicate definitions across markdown files |

### Enhanced `bin/doc-health-audit.sh`

New governance checks added to the existing health audit:
- CLAUDE.md line count (target: <100)
- CLAUDE.md content duplication with docs/
- Large files (>200 lines) missing TOC
- Archive leaks (archived docs still referenced in CLAUDE.md)
- AI Friendliness score (0-5)

### Fixes

- CLAUDE.md, SKILL.md, TODOS.md, LICENSE.md, VERSION.md added to orphaned docs whitelist (fixes false YELLOW on clean projects)

### Design principles

- **Update before organize** — docs must be accurate before restructuring
- **Corrections auto-execute** — broken links and stale refs are bugs, not preferences
- **200-line TOC threshold** — files >200 lines get `## 目录` automatically
- **Archive over delete** — non-essential content preserved, not destroyed
- **Authority hierarchy** — `docs/state-files.md` > `docs/{domain}.md` > `README.md` > `CLAUDE.md`

---

## v2.4.0 — Real Code Review, Env-Aware Execution, Shared Tooling

- `/10review` gains self-check gate + deep code review (logic, security, boundary conditions)
- `/10exec` detects test frameworks (jest/vitest/pytest/go/cargo/shell), runs tests after every stage
- Stage-level code review in `/10exec` (R5 + R7 + R9 + deep review, P1 auto-blocks)
- Shared scripts: `bin/detect-root.sh`, `bin/detect-env.sh`
- Boundary guard: `realpath` canonicalization, `.10dev/` exemption

## v2.3.1 — Agent Behavior Rules

- 8 behavioral rules injected into CLAUDE.md during `/10dev` setup

## v2.3.0 — Developer Profile & Cross-Project Learning

- Three-layer learning: L0 project lessons, L1 developer blind spots, L2 universal principles
- `/10profile` command for viewing/managing developer profile
- WATCH LIST in `/10plan` based on developer blind spots
- Safe write protocol for concurrent session protection
