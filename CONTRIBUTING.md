# Contributing

Thanks for contributing.

This repository is intentionally small. Changes should make the skill clearer, more reusable, and safer to publish as a generic public artifact.

## Contribution Goals

Good contributions usually do one of the following:

- Clarify when the skill should or should not be used
- Improve the wording of the workflow without adding unnecessary bulk
- Strengthen review, failure-path, or validation guidance
- Improve examples while keeping them generic and privacy-safe
- Fix ambiguity that would cause inconsistent behavior in real use

## What To Avoid

Please avoid changes that make the repository more personal, more proprietary, or more complicated than necessary.

Examples to avoid:

- Personal names, emails, or social links
- Company-specific acronyms, systems, or process names
- Internal URLs, issue IDs, customer references, or private data
- Framework-specific rules unless they are clearly optional
- Historical narratives that make the current guidance harder to read

## Writing Principles

- Prefer short, direct wording
- Keep the method general-purpose
- Optimize for reuse across teams, repos, and agents
- Add structure only when it improves execution or review quality
- Preserve the core ten-rule model unless there is a strong reason to change it

## Pull Request Checklist

Before opening a pull request, check that:

- The change keeps the skill general rather than personal
- The wording is still useful for both humans and AI agents
- No private or identifying information has been introduced
- Examples remain generic and safe to publish
- The documentation stays consistent across `README.md`, `README.zh-CN.md`, `SKILL.md`, `agents/openai.yaml`, and `references/`

## Suggested Change Types

### Improve Wording

Tighten phrasing, remove redundancy, or reduce ambiguity.

### Improve Examples

Add or revise examples that make the workflow easier to apply in practice.

### Improve Boundaries

Clarify the difference between in-scope and out-of-scope use cases.

### Improve Reviewability

Strengthen failure-mode checks, review prompts, or validation guidance.

## How To Submit

1. Fork the repository.
2. Create a focused branch.
3. Make the smallest coherent change that solves the problem.
4. Explain the change and why it improves reuse, clarity, or safety.
5. Open a pull request.

## Privacy Checklist

This project is meant to be publishable without exposing personal information. Before submitting, remove:

- Real names
- Email addresses
- Employer or client names
- Internal document titles
- Private repository names
- Internal ticket references
- Sensitive screenshots or logs

If you are unsure whether something is too specific, generalize it before submitting.

## License For Contributions

By submitting a contribution to this repository, you agree that your contribution may be distributed under the MIT License used by this project, unless a different arrangement is explicitly discussed in advance.
