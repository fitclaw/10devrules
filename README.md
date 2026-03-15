# Ten Development Rules

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](./CONTRIBUTING.md)
[![Docs](https://img.shields.io/badge/Docs-English%20%26%20%E4%B8%AD%E6%96%87-blue.svg)](./README.zh-CN.md)
[![Maintained](https://img.shields.io/badge/Maintained-yes-success.svg)](./README.md)

English | [简体中文](./README.zh-CN.md)

Boundary-first, contract-first guidance for software development teams and AI coding agents.

`ten-development-rules` is a general-purpose `SKILL.md` that helps keep work scoped, contracts stable, dependencies ordered, new complexity isolated, and delivery closed with review plus verification.

## Table of Contents

- [Why This Skill Exists](#why-this-skill-exists)
- [Who It Is For](#who-it-is-for)
- [What It Teaches](#what-it-teaches)
- [When To Use It](#when-to-use-it)
- [When Not To Use It](#when-not-to-use-it)
- [Quick Start](#quick-start)
- [Example Prompts](#example-prompts)
- [Repository Structure](#repository-structure)
- [Privacy And Publishing](#privacy-and-publishing)
- [FAQ](#faq)
- [Contributing](#contributing)
- [Security](#security)
- [License](#license)

## Why This Skill Exists

Many software tasks fail before the code is written. Scope expands without agreement. Consumers depend on unstable contracts. Shared code absorbs speculative abstractions. Review and verification happen too late.

This skill gives a lightweight default workflow for those failure modes:

- Define the boundary before designing the solution.
- Freeze shared contracts before parallel work starts.
- Sequence implementation from lower dependencies upward.
- Keep new complexity local until reuse is justified.
- Treat review, failure handling, and verification as part of delivery.

## Who It Is For

- AI coding agents that support `SKILL.md`-style workflows or repository instructions
- Engineers planning features, restructures, refactors, and reviews
- Teams that want a small, reusable method instead of a heavyweight process

## What It Teaches

The skill is organized around ten reusable rules:

1. Set the boundary.
2. Freeze the contract.
3. Sequence by dependency.
4. Stage the work.
5. Isolate new complexity.
6. Build the review loop.
7. Design failure paths.
8. Compress documentation.
9. Verify reality.
10. Distill reusable principles.

## When To Use It

Use this skill when the work benefits from structure before execution:

- Planning a feature before implementation starts
- Breaking a large task into staged deliverables
- Reviewing code for hidden risk, drift, or missing validation
- Refactoring a system while protecting shared contracts
- Turning a one-off project into reusable engineering principles

## When Not To Use It

This skill is intentionally general, but it should not be applied everywhere:

- Very small edits where the workflow would cost more than it saves
- Open-ended ideation where loose exploration is the goal
- Domains that already require a stricter formal process

## Quick Start

### Option 1: Use It As A Standalone Skill

1. Keep `SKILL.md` in this repository or in your local skill collection.
2. Load it into any agent workflow that can consume markdown-based instructions.
3. Invoke it when planning, reviewing, restructuring, or executing software work.

### Option 2: Use It As Repository Guidance

1. Keep `SKILL.md` as the source of truth.
2. Reference or adapt selected sections in your repo-level AI instructions.
3. Preserve the core rules and customize only examples or domain-specific wording.

## Example Prompts

- "Use ten-development-rules to turn this feature request into a staged implementation plan."
- "Review this PR with ten-development-rules and check for scope drift, contract drift, and missing failure handling."
- "Restructure this migration into dependency-ordered phases using ten-development-rules."
- "Summarize the lessons from this project as reusable principles with ten-development-rules."

## Repository Structure

```text
.
├── SKILL.md
├── README.md
├── README.zh-CN.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
└── LICENSE
```

## Privacy And Publishing

This repository is designed to be safe to publish as a generic workflow guide:

- No personal names, emails, or organization-specific identifiers are required.
- No telemetry, analytics, or external services are needed.
- No internal customer data, issue IDs, or private URLs are referenced.
- Public examples are intentionally generic and should stay that way.

If you adapt this skill for internal use, keep internal examples and operational details in a separate private repository.

## FAQ

### Is this only for AI agents?

No. The structure works for both humans and agents. Agents benefit from the explicit workflow. Humans benefit from the reduced ambiguity.

### Is this tied to a specific language or framework?

No. The rules are language-agnostic and tool-agnostic by design.

### Is this a project management framework?

Not in the heavyweight sense. It is a compact execution and review heuristic for software work.

### Can I modify it for my team?

Yes. The safest pattern is to preserve the core rules and adapt the examples, review checklists, or domain vocabulary around them.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for contribution guidelines, privacy rules, and change expectations.

## Security

See [SECURITY.md](./SECURITY.md) for how to report prompt, workflow, or repository-level security concerns without disclosing sensitive information.

## License

This project is released under the MIT License. In practical terms, that means you may use, copy, modify, merge, publish, distribute, sublicense, and sell copies of this project.

The main conditions are simple:

- Keep the original copyright notice
- Keep the license text with substantial copies of the project
- Understand that the project is provided "as is", without warranty

Unless stated otherwise, contributions submitted to this repository are understood to be offered under the same MIT License.

See [LICENSE](./LICENSE) for the full text.
