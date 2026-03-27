# Contributing

Thanks for contributing to **ten-dev-rules** — an agent-driven development workflow skill.

This repository is intentionally small. Changes should make the skill clearer, more reusable, and safer to publish as a generic public artifact.

## Project Overview

`ten-dev-rules` is a `SKILL.md` agent skill for Claude Code and compatible AI harnesses. It has:

- **`SKILL.md`** — The core agent skill with four operating modes (PLAN / EXECUTE / REVIEW / DISTILL)
- **`bin/check-boundary.sh`** — Optional PreToolUse hook enforcing Rule 1 (scope boundary)
- **`README.md` / `README.zh-CN.md`** — Documentation in English and Chinese

## Contribution Goals

Good contributions usually do one of the following:

- Improve decision gate logic in the four operating modes
- Strengthen the hook enforcement or add new optional hooks for other rules
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
- [ ] `README.md`, `README.zh-CN.md`, and `SKILL.md` stay consistent
- [ ] Hook scripts (if modified) handle edge cases: missing files, empty input, parse failures
- [ ] YAML frontmatter in `SKILL.md` remains valid

## Suggested Change Types

### Mode Improvements

Refine the PLAN / EXECUTE / REVIEW / DISTILL workflow phases, decision gates, or output formats.

### Hook Enhancements

Improve `check-boundary.sh` or propose new hooks for other rules (e.g., verification enforcement for Rule 9).

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
# No boundary file → should output {}
echo '{"tool_input":{"file_path":"any/file.py"}}' | bash bin/check-boundary.sh

# File inside boundary → should output {}
mkdir -p .10dev && echo "src/" > .10dev/boundary.txt
echo '{"tool_input":{"file_path":"src/main.py"}}' | bash bin/check-boundary.sh

# File outside boundary → should output permissionDecision: "ask"
echo '{"tool_input":{"file_path":"docs/readme.md"}}' | bash bin/check-boundary.sh
rm -rf .10dev
```

## Privacy Checklist

Before submitting, remove: real names, email addresses, employer/client names, internal document titles, private repo names, internal ticket references, sensitive screenshots or logs.

## License For Contributions

By submitting a contribution, you agree that it may be distributed under the MIT License used by this project, unless a different arrangement is explicitly discussed in advance.
