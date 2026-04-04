# Ten Development Rules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Docs](https://img.shields.io/badge/Docs-English%20%26%20%E4%B8%AD%E6%96%87-blue.svg)](./README.zh-CN.md)
[![Version](https://img.shields.io/badge/version-2.3.1-blue.svg)](./SKILL.md)

English | [简体中文](./README.zh-CN.md)

> **AI writes code fast. This skill makes it write code *right*.**

`ten-dev-rules` is an agent skill for [Claude Code](https://claude.ai/claude-code) that transforms 10 engineering rules into **active decision gates** — the AI must scope before coding, freeze contracts before building, verify before shipping. No ceremony, just discipline.

## Why This Exists

AI coding assistants are powerful but undisciplined. Without guardrails, they:

- Start coding before understanding the scope
- Modify shared interfaces without freezing contracts
- Skip failure path design and ship happy-path-only code
- Repeat the same mistakes across different projects

`ten-dev-rules` fixes this by making the AI **enforce engineering discipline on itself** — and **learn from your mistakes** across projects.

## 8 Commands

| Command | Type | What It Does |
|---------|------|-------------|
| `/10dev` | Entry | Onboarding, project scan, status dashboard |
| `/10plan` | Mode | Scope boundary -> freeze contracts -> sequence deps -> stage work -> WATCH LIST |
| `/10exec` | Mode | Isolate complexity -> implement -> review loop -> verify -> record lessons |
| `/10review` | Mode | Audit code/PR against all 10 rules -> SHIP / BLOCK verdict + profile match |
| `/10distill` | Mode | Extract principles -> update developer profile -> cross-project pattern detection |
| `/10docs` | Mode | Audit doc health -> cleanup stale artifacts -> sync to Obsidian vault |
| `/10profile` | Tool | View/manage developer blind spots, preferences, and progress |

All modes also trigger via natural language: "plan this feature", "review this PR", "what did we learn", etc.

**New to 10devrules? Start with `/10dev`** — it guides you through setup and launches your first mode.

## The Ten Rules

| # | Rule | What the Agent Does |
|---|------|---------------------|
| 1 | **Set the boundary** | Defines solves/defers/removed. Hook blocks out-of-scope edits. |
| 2 | **Freeze the contract** | Stabilizes interfaces before consumers are built. Writes `.10dev/contract.md`. |
| 3 | **Sequence by dependency** | Builds foundations first. Flags circular deps for resolution. |
| 4 | **Stage the work** | Splits into phases with entry/exit conditions and predicted file lists. |
| 5 | **Isolate new complexity** | New logic in new files. Shared core edits require justification. |
| 6 | **Build the review loop** | Every stage: implement -> review -> fix -> re-verify. |
| 7 | **Design failure paths** | Enumerates unhappy paths per stage. Zero failure paths = hard stop. |
| 8 | **Compress documentation** | Living specs, not history. Minimum docs that restore context. |
| 9 | **Verify reality** | Must state verified/skipped/risk before marking done. |
| 10 | **Distill reusable principles** | Extracts patterns using action verbs: scope, freeze, isolate, verify. |

Each rule is a **gate**, not a suggestion. The agent enforces them at specific workflow points.

## Quick Start

### 30-Second Setup

```bash
# Clone into your Claude Code skills directory
git clone https://github.com/fitclaw/10devrules.git ~/.claude/skills/ten-dev-rules

# Register per-mode slash commands
cd ~/.claude/skills
for cmd in 10dev 10plan 10exec 10review 10distill 10docs 10profile; do
  ln -sf ten-dev-rules/skills/$cmd $cmd
done

# Done. Type /10dev to get started.
```

### Try It

```
You:   /10dev
Agent: [Detects new project, scans environment, offers CLAUDE.md routing setup]
       -> Environment ready. What would you like to do first?

You:   /10plan Add user authentication with OAuth
Agent: [Sets boundary, freezes contracts, sequences deps, stages work, shows WATCH LIST]
       -> Structured plan with 4 stages, frozen contracts, failure paths, and profile warnings

You:   /10exec
Agent: [For each stage: isolate -> implement -> review -> verify -> update]
       -> Code delivered with file drift detection and verification records

You:   /10review
Agent: [Audits diff against all 10 rules, matches findings against profile]
       -> SHIP_WITH_CONCERNS: Rule 7 missing timeout handling. Profile match: known blind spot.

You:   /10distill
Agent: [Extracts patterns, compares against developer profile]
       -> 2 principles extracted. Profile updated: "Skips failure paths" frequency 2->3.

You:   /10profile
Agent: -> 3 blind spots tracked (1 HIGH, 2 MEDIUM). Last healed: "Assumes platform behavior".

You:   /10docs
Agent: [Scans todo.md, lessons.md, contracts for staleness]
       -> GREEN: All documents healthy. 0 stale tasks.
```

## Developer Profile: Three-Layer Learning

10devrules learns from your mistakes across projects.

```text
L0: Project lessons (lessons.md)         -> what we learned THIS project
L1: Developer blind spots (profile)      -> recurring patterns across projects
L2: Universal principles                 -> abstracted, project-independent
```

The profile lives at `~/.10dev/developer-profile.md` (global). When you run `/10plan`, it reads your profile and generates a **WATCH LIST** — proactive warnings based on your known blind spots. When you run `/10distill`, it compares new lessons against your profile and proposes updates.

```
## WATCH LIST (from developer profile)

! HIGH: Assumes platform behavior
  Trigger: Developing plugins/extensions for a host platform
  Defense: Add task — "Verify platform's extension discovery mechanism"
  - [ ] Acknowledged: Assumes platform behavior

MEDIUM: Skips failure path design
  Trigger: Feature development enters "excitement" phase
  Defense: Rule 7 gate — enumerate unhappy paths per stage
```

Features:
- **Keyword-based matching** with agent judgment fallback
- **Safe write protocol** (atomic mv + .bak backup) for concurrent session protection
- **Blind spot healing** — auto-propose severity downgrade after 6 months quiet
- **Distill diff** — see what changed in your profile after each /10distill
- **Profile export** — anonymized markdown for sharing

## Agent Behavior Rules

10devrules enforces 8 behavioral rules on the AI agent, active in every mode:

1. Think before acting — read existing files before writing code
2. Concise output, thorough reasoning
3. Prefer editing over rewriting whole files
4. Do not re-read files already in context
5. Test before declaring done
6. No sycophantic openers or closing fluff
7. Keep solutions simple and direct
8. User instructions always override skill instructions

These are injected into your project's CLAUDE.md during `/10dev` setup, so they apply to every session — even outside 10dev modes.

## Architecture

v2.3 uses a **router-layer architecture** with per-mode skill wrappers.

```text
SKILL.md (router)          docs/ (mode logic)           skills/ (slash commands)
+-----------------+       +--------------------+       +--------------------+
| Rules table     |       | 10plan.md          |       | 10dev/   (entry)   |
| Mode router     |------>| 10exec.md          |       | 10plan/  10exec/   |
| Output templates|       | 10review.md        |       | 10review/ 10distill|
| Anti-patterns   |       | 10distill.md       |       | 10docs/ 10profile/ |
| State files     |       | 10docs.md          |       +--------------------+
| Tool commands   |       | 10dev.md           |       bin/ (enforcement)
+-----------------+       | state-files.md     |       +--------------------+
                          +--------------------+       | check-boundary.sh  |
                                                       | doc-health-audit.sh|
                                                       | doc-sync.sh        |
                                                       +--------------------+

Global state (~/.10dev/):
  developer-profile.md    L1 blind spots + preferences
  universal-principles.md L2 abstracted principles
  projects.txt            project registry
  .onboarded              onboarding flag
```

## DOCS Mode: Obsidian Integration

`/10docs` manages document health and cross-version memory via Obsidian:

| Sub-Command | What It Does |
|-------------|-------------|
| `/10docs audit` | Detect stale tasks, untagged lessons, contract drift, orphaned docs |
| `/10docs cleanup` | Phase-aware archival: snapshot completed work, start fresh |
| `/10docs sync` | Push state files to Obsidian vault with YAML frontmatter |
| `/10docs snapshot` | Create versioned decision records (ADR) |
| `/10docs index` | Rebuild phase-aware reading order |

## Hook System

The optional boundary guard hook enforces Rule 1:

- Reads `.10dev/boundary.txt` (allowed edit paths)
- Checks every `Edit` and `Write` against scope
- **Advisory mode** (`ask`, not `deny`) — you always decide
- No boundary file = all edits allowed
- Directory-safe matching (prevents `/src` from matching `/src-old`)

## Repository Structure

```text
.
+-- SKILL.md                  # Router layer (v2.3)
+-- docs/
|   +-- 10plan.md             # PLAN mode (7 phases + WATCH LIST)
|   +-- 10exec.md             # EXECUTE mode (stage loop + file drift detection)
|   +-- 10review.md           # REVIEW mode (10-rule audit + profile match)
|   +-- 10distill.md          # DISTILL mode (4 phases + 3-layer learning)
|   +-- 10docs.md             # DOCS mode (Obsidian sync)
|   +-- 10dev.md              # /10dev orchestrator logic
|   +-- state-files.md        # Canonical state file schemas
+-- skills/
|   +-- 10dev/                # /10dev entry point
|   +-- 10plan/ ... 10profile/  # Per-mode slash command wrappers
+-- bin/
|   +-- check-boundary.sh     # Rule 1 boundary guard
|   +-- doc-health-audit.sh   # Document health check
|   +-- doc-sync.sh           # Obsidian vault sync engine
+-- README.md / README.zh-CN.md / CONTRIBUTING.md / SECURITY.md
```

## When To Use It

- **Before coding** — scope the work, freeze contracts, plan stages
- **During coding** — isolated stages with review loops and verification
- **After coding** — audit PRs against 10 rules, extract principles
- **Across projects** — developer profile carries your lessons forward

## When Not To Use It

- Trivial one-line fixes (the workflow costs more than the change)
- Pure brainstorming (loose exploration is the goal)
- Domains with stricter formal processes that supersede this

## FAQ

**Is this only for AI agents?**
No. Humans and agents both benefit. Agents get explicit workflows. Humans get reduced ambiguity.

**Is this tied to a language or framework?**
No. Language-agnostic and tool-agnostic.

**Can I use it without the hook?**
Yes. The hook is optional. All rules work as agent instructions in `SKILL.md` alone.

**What dependencies does it need?**
Only `bash`, `grep`, `sed`. Standard on macOS and Linux. No npm, no pip, no Docker.

**What's the developer profile?**
A global file (`~/.10dev/developer-profile.md`) that tracks your recurring coding blind spots. `/10plan` reads it to warn you proactively. `/10distill` updates it. Fully optional — created automatically when you first run `/10distill`.

**Can I modify it for my team?**
Yes. MIT licensed. Preserve the core rules and adapt everything else.

## Privacy

- No telemetry, analytics, or external services
- No personal data required
- Developer profile is local only (`~/.10dev/`)
- All examples are generic
- Safe to use in any organization

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Security

See [SECURITY.md](./SECURITY.md).

## License

MIT License. See [LICENSE](./LICENSE).
