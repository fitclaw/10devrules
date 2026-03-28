# Contributing

Thanks for contributing to **ten-dev-rules** — an agent-driven development workflow skill.

This repository is intentionally small. Changes should make the skill clearer, more reusable, and safer to publish as a generic public artifact.

## Project Overview

`ten-dev-rules` is a `SKILL.md` agent skill for Claude Code with a router-layer architecture:

- **`SKILL.md`** — Router layer with rules table, mode router, and output templates
- **`docs/`** — Detailed logic for each mode (10plan.md, 10exec.md, 10review.md, 10distill.md, 10docs.md)
- **`bin/`** — Shell scripts: boundary guard hook, doc health audit, Obsidian vault sync
- **`README.md` / `README.zh-CN.md`** — Documentation in English and Chinese

## Contribution Goals

Good contributions usually do one of the following:

- Improve decision gate logic in the five operating modes
- Strengthen hook enforcement or add new optional hooks for other rules
- Improve the DOCS mode (Obsidian sync, health audit, cleanup logic)
- Clarify when the skill should or should not be used
- Improve wording without adding unnecessary bulk
- Strengthen review, failure-path, or validation guidance
- Improve examples while keeping them generic and privacy-safe
- Fix ambiguity that would cause inconsistent behavior in real use
- Add translations or improve i18n quality

## What To Avoid

- Personal names, emails, or social links
- Company-specific acronyms, systems, or process names
- Internal URLs, issue IDs, customer references, or private data
- Framework-specific rules unless clearly optional
- Historical narratives that make current guidance harder to read
- Breaking changes to the YAML frontmatter schema without discussion

## Writing Principles

- Prefer short, direct wording
- Keep the method general-purpose and language-agnostic
- Optimize for reuse across teams, repos, and agents
- Add structure only when it improves execution or review quality
- Preserve the core ten-rule model unless there is a strong reason to change it
- Hooks should be advisory (`ask`) by default, not blocking (`deny`)

## Pull Request Checklist

Before opening a pull request, check that:

- [ ] The change keeps the skill general rather than personal
- [ ] The wording works for both humans and AI agents
- [ ] No private or identifying information was introduced
- [ ] Examples remain generic and safe to publish
- [ ] `SKILL.md`, `docs/`, and both READMEs stay consistent
- [ ] Hook/bin scripts handle edge cases: missing files, empty input, parse failures
- [ ] YAML frontmatter in `SKILL.md` remains valid

## Suggested Change Types

### Mode Improvements

Refine PLAN / EXECUTE / REVIEW / DISTILL / DOCS workflow phases, decision gates, or output formats. Each mode's logic lives in `docs/10*.md`.

### Hook & Script Enhancements

Improve `check-boundary.sh`, `doc-health-audit.sh`, `doc-sync.sh`, or propose new hooks for other rules.

### DOCS Mode Improvements

Enhance Obsidian vault sync, health audit logic, cleanup procedures, or ADR generation.

### Wording Improvements

Tighten phrasing, remove redundancy, or reduce ambiguity.

### Translation

Improve `README.zh-CN.md` quality or add new language translations.

## How To Submit

1. Fork the repository.
2. Create a focused branch (`improve-plan-mode`, `add-rule9-hook`, etc.).
3. Make the smallest coherent change that solves the problem.
4. Explain the change and why it improves reuse, clarity, or safety.
5. Open a pull request.

## Testing Hook Changes

If you modify `bin/check-boundary.sh`, test these three scenarios:

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

If you modify `bin/doc-health-audit.sh`, test with and without state files:

```bash
# No state files -> should output GREEN health
bash bin/doc-health-audit.sh . 7

# With state files -> verify counts are correct
echo "- [x] Done task" > todo.md
bash bin/doc-health-audit.sh . 0
rm todo.md
```

## Privacy Checklist

Before submitting, remove: real names, email addresses, employer/client names, internal document titles, private repo names, internal ticket references, sensitive screenshots or logs.

## License For Contributions

By submitting a contribution, you agree that it may be distributed under the MIT License used by this project, unless a different arrangement is explicitly discussed in advance.
