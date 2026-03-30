# Ten Development Rules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Docs](https://img.shields.io/badge/Docs-English%20%26%20%E4%B8%AD%E6%96%87-blue.svg)](./README.zh-CN.md)
[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](./SKILL.md)

English | [简体中文](./README.zh-CN.md)

> **AI writes code fast. This skill makes it write code *right*.**

`ten-dev-rules` is an agent skill for [Claude Code](https://claude.ai/claude-code) that transforms 10 engineering rules into **active decision gates** — the AI must scope before coding, freeze contracts before building, verify before shipping. No ceremony, just discipline.

## Why This Exists

AI coding assistants are powerful but undisciplined. Without guardrails, they:

- Start coding before understanding the scope
- Modify shared interfaces without freezing contracts
- Skip failure path design and ship happy-path-only code
- Accumulate stale docs that poison future context

`ten-dev-rules` fixes this by making the AI **enforce engineering discipline on itself** — automatically.

## 5 Modes, 5 Commands

| Command | Mode | What It Does |
|---------|------|-------------|
| `/10plan` | **PLAN** | Scope boundary -> freeze contracts -> sequence dependencies -> stage work -> audit failure paths |
| `/10exec` | **EXECUTE** | Isolate new complexity -> implement -> review loop -> verify reality -> record lessons |
| `/10review` | **REVIEW** | Audit code/PR against all 10 rules -> SHIP / SHIP_WITH_CONCERNS / BLOCK verdict |
| `/10distill` | **DISTILL** | Extract reusable principles from completed work -> one-line summary formula |
| `/10docs` | **DOCS** | Audit doc health -> cleanup stale artifacts -> sync to Obsidian vault -> snapshot decisions |

All modes also trigger via natural language: "plan this feature", "review this PR", "sync docs", etc.

## The Ten Rules

| # | Rule | What the Agent Does |
|---|------|---------------------|
| 1 | **Set the boundary** | Defines solves/defers/removed. Hook blocks out-of-scope edits. |
| 2 | **Freeze the contract** | Stabilizes interfaces before consumers are built. Blocks if unstable. |
| 3 | **Sequence by dependency** | Builds foundations first. Flags circular deps for resolution. |
| 4 | **Stage the work** | Splits into phases with entry/exit conditions. No oversized passes. |
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

# Done. Start any development task and the skill activates automatically.
```

Or copy `SKILL.md` + `docs/` + `bin/` manually to your preferred location.

### Try It

```
You:   /10plan Add user authentication with OAuth
Agent: [Sets boundary, discovers existing interfaces, sequences deps, stages work, audits failure paths]
       -> Structured plan with 4 stages, frozen contracts, and failure paths enumerated

You:   /10exec
Agent: [For each stage: isolate -> implement -> review -> verify -> update]
       -> Code delivered with verification records per stage

You:   /10review
Agent: [Audits diff against all 10 rules]
       -> SHIP_WITH_CONCERNS: Rule 7 missing timeout handling on token refresh

You:   /10distill
Agent: [Extracts patterns, compares against developer profile]
       -> 2 principles extracted. Profile updated: "Skips failure paths" frequency 2→3.

You:   /10profile
Agent: -> 3 blind spots tracked (1 HIGH, 2 MEDIUM). Pattern "Assumes platform behavior" healed.

You:   /10docs
Agent: [Scans todo.md, lessons.md, contracts for staleness]
       -> YELLOW: 3 stale tasks, 2 untagged lessons. Recommendation: run /10docs cleanup
```

New to 10devrules? Start with `/10dev` — it guides you through setup and launches your first mode.

## Architecture: Router + Agent Cluster

v2.2 uses a **router-layer architecture** with per-mode skill wrappers and a three-layer learning system.

```text
SKILL.md (router)          docs/ (mode logic)           skills/ (slash commands)
┌──────────────────┐      ┌─────────────────────┐      ┌────────────────────┐
│ Rules table      │      │ 10plan.md           │      │ 10dev/   (entry)   │
│ Mode router      │─────>│ 10exec.md           │      │ 10plan/  10exec/   │
│ Output templates │      │ 10review.md         │      │ 10review/ 10distill│
│ Anti-patterns    │      │ 10distill.md        │      │ 10docs/ 10profile/ │
│ State files      │      │ 10docs.md           │      └────────────────────┘
│ Tool commands    │      │ 10dev.md            │      bin/ (enforcement)
└──────────────────┘      │ state-files.md      │      ┌────────────────────┐
                          └─────────────────────┘      │ check-boundary.sh  │
                                                       │ doc-health-audit.sh│
                                                       │ doc-sync.sh        │
                                                       └────────────────────┘
```

### Developer Profile (Three-Layer Learning)

```text
L0: Project lessons (lessons.md)     — what we learned THIS project
L1: Developer blind spots (profile)  — recurring patterns across projects
L2: Universal principles             — abstracted, project-independent
```

The profile lives at `~/.10dev/developer-profile.md` (global, cross-project). `/10plan` reads it to generate a WATCH LIST. `/10distill` updates it. `/10profile` views and manages it.

## DOCS Mode: Obsidian Integration

`/10docs` manages document health and cross-version memory via Obsidian:

| Sub-Command | What It Does |
|-------------|-------------|
| `/10docs audit` | Detect stale tasks, untagged lessons, contract drift, orphaned docs |
| `/10docs cleanup` | Phase-aware archival: snapshot completed work, start fresh |
| `/10docs sync` | Push state files to Obsidian vault with YAML frontmatter |
| `/10docs snapshot` | Create versioned decision records (ADR) |
| `/10docs index` | Rebuild phase-aware reading order |

Vault structure:
```
~/dev-vault/projects/{project}/
├── _index.md        # Auto-generated reading order
├── active/          # Current phase docs (with frontmatter)
├── archive/         # Completed phase snapshots
├── decisions/       # Versioned ADRs
└── lessons/         # Organized by topic
```

## Hook System

The optional boundary guard hook enforces Rule 1:

- Reads `.10dev/boundary.txt` (allowed edit paths)
- Checks every `Edit` and `Write` against scope
- **Advisory mode** (`ask`, not `deny`) — you always decide
- No boundary file = all edits allowed

```bash
mkdir -p .10dev
echo "src/features/auth" > .10dev/boundary.txt
```

## Repository Structure

```text
.
├── SKILL.md                  # Router layer
├── docs/
│   ├── 10plan.md             # PLAN mode logic
│   ├── 10exec.md             # EXECUTE mode logic
│   ├── 10review.md           # REVIEW mode logic
│   ├── 10distill.md          # DISTILL mode logic
│   └── 10docs.md             # DOCS mode (Obsidian sync)
├── bin/
│   ├── check-boundary.sh     # Rule 1 boundary guard
│   ├── doc-health-audit.sh   # Document health check
│   └── doc-sync.sh           # Obsidian vault sync engine
├── README.md
├── README.zh-CN.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

## When To Use It

- **Before coding** — scope the work, freeze contracts, plan stages
- **During coding** — isolated stages with review loops and verification
- **After coding** — audit PRs against 10 rules, extract principles
- **Ongoing** — keep docs healthy, sync decisions to Obsidian

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

**Can I modify it for my team?**
Yes. MIT licensed. Preserve the core rules and adapt everything else.

## Privacy

- No telemetry, analytics, or external services
- No personal data required
- All examples are generic
- Safe to use in any organization

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Security

See [SECURITY.md](./SECURITY.md).

## License

MIT License. See [LICENSE](./LICENSE).
