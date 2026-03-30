# Contributing

Thanks for contributing to **ten-dev-rules** — an agent-driven development workflow skill with a three-layer learning system.

This repository is intentionally small. Changes should make the skill clearer, more reusable, and safer to publish as a generic public artifact.

## Project Overview

`ten-dev-rules` is a `SKILL.md` agent skill for Claude Code with a router-layer architecture:

- **`SKILL.md`** — Router layer with rules table, mode router, output templates, and tool commands
- **`docs/`** — Detailed logic for each mode (10plan.md, 10exec.md, 10review.md, 10distill.md, 10docs.md, 10dev.md) + state file schemas (state-files.md)
- **`skills/`** — Per-mode slash command wrappers (10dev, 10plan, 10exec, 10review, 10distill, 10docs, 10profile)
- **`bin/`** — Shell scripts: boundary guard hook, doc health audit, Obsidian vault sync
- **`README.md` / `README.zh-CN.md`** — Documentation in English and Chinese

### Command Types

- **5 work modes**: /10plan, /10exec, /10review, /10distill, /10docs (in Mode Router table)
- **2 tool commands**: /10dev (orchestrator), /10profile (profile viewer)

### State Files

- **Local** (per-project): `todo.md`, `lessons.md`, `.10dev/boundary.txt`, `.10dev/contract.md`
- **Global** (`~/.10dev/`): `developer-profile.md`, `universal-principles.md`, `projects.txt`
- See `docs/state-files.md` for canonical schemas and examples

## Contribution Goals

Good contributions usually do one of the following:

- Improve decision gate logic in the five operating modes
- Strengthen hook enforcement or add new optional hooks for other rules
- Improve the three-layer learning system (L0/L1/L2 promotion, profile matching)
- Improve the DOCS mode (Obsidian sync, health audit, cleanup logic)
- Improve the /10dev onboarding flow
- Clarify when the skill should or should not be used
- Improve wording without adding unnecessary bulk
- Fix cross-file consistency (SKILL.md, docs/*.md, skills/*/SKILL.md must agree)
- Add translations or improve i18n quality

## What To Avoid

- Personal names, emails, or social links
- Company-specific acronyms, systems, or process names
- Internal URLs, issue IDs, customer references, or private data
- Framework-specific rules unless clearly optional
- Breaking changes to state file schemas without discussion (see docs/state-files.md)
- Modifying global state files (~/.10dev/*) without safe write protocol

## Writing Principles

- Prefer short, direct wording
- Keep the method general-purpose and language-agnostic
- Optimize for reuse across teams, repos, and agents
- Hooks should be advisory (`ask`) by default, not blocking (`deny`)
- State file changes must update docs/state-files.md

## Pull Request Checklist

Before opening a pull request, check that:

- [ ] The change keeps the skill general rather than personal
- [ ] The wording works for both humans and AI agents
- [ ] No private or identifying information was introduced
- [ ] `SKILL.md`, `docs/`, `skills/*/SKILL.md`, and both READMEs stay consistent
- [ ] Hook/bin scripts handle edge cases: missing files, empty input, parse failures
- [ ] State file format changes update `docs/state-files.md`
- [ ] YAML frontmatter in `SKILL.md` remains valid
- [ ] New commands are registered in both Mode Router (modes) or Tool Commands (tools) table

## Suggested Change Types

### Mode Improvements
Refine PLAN / EXECUTE / REVIEW / DISTILL / DOCS workflow phases. Each mode's logic lives in `docs/10*.md`.

### Developer Profile & Learning System
Improve L0->L1->L2 promotion logic, keyword matching, safe write protocol, or profile display.

### Onboarding (/10dev)
Improve the orchestrator entry point, project scanning, CLAUDE.md routing, or dashboard.

### Hook & Script Enhancements
Improve `check-boundary.sh`, `doc-health-audit.sh`, `doc-sync.sh`, or propose new hooks.

### Slash Command Wrappers
Improve the per-mode skill wrappers in `skills/*/SKILL.md`. All wrappers must support three root-discovery fallbacks: readlink -> CLAUDE_SKILL_DIR -> dirname.

## Testing

### Hook Changes

```bash
# No boundary file -> should output {}
echo '{"tool_input":{"file_path":"any/file.py"}}' | bash bin/check-boundary.sh

# File inside boundary -> should output {}
mkdir -p .10dev && echo "src/" > .10dev/boundary.txt
echo '{"tool_input":{"file_path":"src/main.py"}}' | bash bin/check-boundary.sh

# File outside boundary -> should output permissionDecision: "ask"
echo '{"tool_input":{"file_path":"docs/readme.md"}}' | bash bin/check-boundary.sh
rm -rf .10dev
```

### Doc Health Audit

```bash
# No state files -> should output GREEN health with valid JSON
bash bin/doc-health-audit.sh . 7

# With state files -> verify counts
echo "- [x] Done task" > todo.md && bash bin/doc-health-audit.sh . 0 && rm todo.md
```

## How To Submit

1. Fork the repository.
2. Create a focused branch (`improve-plan-mode`, `fix-profile-matching`, etc.).
3. Make the smallest coherent change that solves the problem.
4. Explain the change and why it improves reuse, clarity, or safety.
5. Open a pull request.

## License For Contributions

By submitting a contribution, you agree that it may be distributed under the MIT License used by this project, unless a different arrangement is explicitly discussed in advance.
