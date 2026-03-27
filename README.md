# Ten Development Rules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Docs](https://img.shields.io/badge/Docs-English%20%26%20%E4%B8%AD%E6%96%87-blue.svg)](./README.zh-CN.md)
[![Maintained](https://img.shields.io/badge/Maintained-yes-success.svg)](./README.md)

English | [简体中文](./README.zh-CN.md)

An **agent-driven** development workflow that uses 10 rules as active decision gates — not just a reference list.

`ten-dev-rules` is a `SKILL.md` agent skill for Claude Code and compatible AI harnesses. It actively orchestrates development work through four operating modes: **PLAN**, **EXECUTE**, **REVIEW**, and **DISTILL**.

## What Changed in v2.0

v1.x was a passive reference document listing 10 rules. v2.0 transforms it into an **active agent** with:

- **Four operating modes** with distinct workflows and structured outputs
- **Decision gates** at each rule — the agent enforces them, not just suggests
- **Hook enforcement** — optional `bin/check-boundary.sh` blocks out-of-scope edits (Rule 1)
- **Sub-agent delegation** — uses Explore agents for contract discovery and dependency analysis
- **State files** — `.10dev/boundary.txt`, `todo.md`, `lessons.md` for cross-session memory
- **Structured outputs** — audit reports, stage completion records, distilled principles

## Table of Contents

- [The Ten Rules](#the-ten-rules)
- [Four Operating Modes](#four-operating-modes)
- [Quick Start](#quick-start)
- [Hook System](#hook-system)
- [Repository Structure](#repository-structure)
- [Example Prompts](#example-prompts)
- [When To Use It](#when-to-use-it)
- [When Not To Use It](#when-not-to-use-it)
- [Privacy And Publishing](#privacy-and-publishing)
- [FAQ](#faq)
- [Contributing](#contributing)
- [Security](#security)
- [License](#license)

## The Ten Rules

Each rule is a **decision gate** enforced at specific points in the workflow:

| # | Rule | Agent Behavior |
|---|------|----------------|
| 1 | **Set the boundary** | Must scope before implementation. Hook blocks out-of-scope edits. |
| 2 | **Freeze the contract** | Must stabilize interfaces before consumers are built. |
| 3 | **Sequence by dependency** | Must build foundations before consumers. |
| 4 | **Stage the work** | Must split into phases with entry/exit conditions. |
| 5 | **Isolate new complexity** | New logic in new files. Shared core edits need justification. |
| 6 | **Build the review loop** | Every stage: implement → review → fix → re-verify. |
| 7 | **Design failure paths** | Must enumerate unhappy paths per stage. |
| 8 | **Compress documentation** | Minimum docs that restore context. Living specs, not history. |
| 9 | **Verify reality** | Must state verified/skipped/risk before marking done. |
| 10 | **Distill reusable principles** | Extract patterns using action verbs. |

## Four Operating Modes

### PLAN Mode

Scope and structure work **before** coding. Six phases with decision gates:

1. **Set Boundary** (R1) → solves / defers / removed
2. **Freeze Contract** (R2) → stabilize interfaces via sub-agent exploration
3. **Sequence by Dependency** (R3) → build order analysis
4. **Stage the Work** (R4) → phases with entry/exit conditions
5. **Failure Path Audit** (R7) → enumerate unhappy paths per stage
6. **Output** → structured plan document

### EXECUTE Mode

Implement staged work with a verification loop:

```
For each stage:
  1. Isolate (R5) — new complexity in new files
  2. Implement — write code
  3. Review Loop (R6) — self-review + tests
  4. Verify (R9) — verified/skipped/risk report
  5. Update — mark done + record lessons
```

Includes self-correction: 3-strike escalation on repeated failures.

### REVIEW Mode

Audit existing code or PRs against all 10 rules:

```
Rule 1  - Boundary:      PASS | DRIFT | VIOLATION
Rule 2  - Contract:      PASS | UNSTABLE | VIOLATION
...
Rule 10 - Distillation:  PASS | SKIPPED | N/A
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Verdict: SHIP | SHIP_WITH_CONCERNS | BLOCK
```

### DISTILL Mode

Extract reusable principles from completed work → one-line summary formula.

## Quick Start

### Option 1: As a Claude Code Skill

1. Copy `SKILL.md` and `bin/` to your Claude Code skills directory.
2. The agent activates when you start a development task.
3. Say "plan this feature" or "review this PR" to trigger specific modes.

### Option 2: As Repository Guidance

1. Keep `SKILL.md` in your project root.
2. Reference it in your `CLAUDE.md` or AI instructions.
3. The 10 rules serve as your development methodology.

### Option 3: Without Hook (Lightweight)

Use only `SKILL.md` without the `bin/` directory. All rules work as agent instructions — the hook is an optional enforcement layer.

## Hook System

The optional `bin/check-boundary.sh` script enforces Rule 1 (Set the boundary):

- Reads `.10dev/boundary.txt` (allowed edit paths, one per line)
- Checks every `Edit` and `Write` operation against the boundary
- **Advisory mode** (`ask`, not `deny`) — the user always decides
- No boundary file → all edits allowed

Set a boundary manually:

```bash
mkdir -p .10dev
echo "src/features/auth" > .10dev/boundary.txt
```

## Repository Structure

```text
.
├── SKILL.md              # Agent skill (the core)
├── bin/
│   └── check-boundary.sh # Optional hook for Rule 1 enforcement
├── README.md
├── README.zh-CN.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
└── LICENSE
```

## Example Prompts

- "Plan this feature using ten-dev-rules" → triggers PLAN mode
- "Review this PR against the 10 rules" → triggers REVIEW mode
- "Implement stage 2 of the plan" → triggers EXECUTE mode
- "What did we learn from this project?" → triggers DISTILL mode
- "Scope this before we start coding" → triggers PLAN Phase 1

## When To Use It

- Planning a feature before implementation
- Breaking large tasks into staged deliverables
- Reviewing code for hidden risk, drift, or missing validation
- Refactoring while protecting shared contracts
- Extracting reusable engineering principles

## When Not To Use It

- Very small edits where the workflow costs more than it saves
- Open-ended ideation where loose exploration is the goal
- Domains with stricter formal processes that supersede this

## Privacy And Publishing

- No personal names, emails, or organization identifiers required
- No telemetry, analytics, or external services
- No internal data, issue IDs, or private URLs
- All examples are intentionally generic

## FAQ

### Is this only for AI agents?

No. The structure works for both humans and agents. Agents benefit from explicit workflows. Humans benefit from reduced ambiguity.

### Is this tied to a specific language or framework?

No. Language-agnostic and tool-agnostic by design.

### Does the hook script require any dependencies?

Only `bash`, `grep`, `sed`, and optionally `python3` (as fallback for JSON parsing). Standard on macOS and Linux.

### Can I use it without the hook?

Yes. The hook is optional. All 10 rules work as agent instructions in `SKILL.md` alone.

### Can I modify it for my team?

Yes. Preserve the core rules and adapt examples, review checklists, or domain vocabulary.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Security

See [SECURITY.md](./SECURITY.md).

## License

MIT License. See [LICENSE](./LICENSE) for full text.
