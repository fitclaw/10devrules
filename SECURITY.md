# Security Policy

This repository ships an AI agent skill (`SKILL.md`), mode detail files (`docs/`), and shell scripts (`bin/`). While it does not run a hosted service, security concerns can still exist.

## Threat Surface

| Area | Risk |
|------|------|
| **Prompt injection** | Malicious instructions hidden in skill files that trick an AI agent into destructive actions |
| **Hook scripts** | `check-boundary.sh` runs as a PreToolUse hook — a compromised version could suppress warnings or exfiltrate file paths |
| **Doc sync scripts** | `doc-sync.sh` writes files to the Obsidian vault — a compromised version could overwrite unrelated files |
| **Unsafe guidance** | Rules or examples that could cause data loss, credential exposure, or destructive commands |
| **Data leaks** | Accidental inclusion of secrets, personal data, or private references in any file |
| **Malicious links** | Untrusted external URLs added to documentation or examples |

## How To Report

If you find a security issue:

1. **Prefer GitHub's private reporting** or security advisory flow when available.
2. If private reporting is not available, open a minimally detailed public issue.
3. **Never post** secrets, tokens, credentials, private URLs, or exploit-ready payloads in public.

## What To Include

- A short description of the problem
- The affected file or section (e.g., `SKILL.md`, `docs/10docs.md`, `bin/doc-sync.sh`)
- Why the issue matters (what could go wrong in real use)
- Safe reproduction steps, if applicable
- A suggested fix, if you have one

## Response Guidelines

Maintainers should aim to:

- Acknowledge the report promptly
- Triage impact and scope
- Remove sensitive material quickly if posted accidentally
- Ship a fix in the smallest safe change

## Script Security

All scripts in `bin/`:

- Read input from stdin or file arguments only
- Do NOT execute commands from user-controlled input (no `eval`, no `exec`)
- Do NOT transmit data to external services
- Do NOT modify files outside their declared scope
- Fall back to safe defaults if parsing fails (fail-open for boundary check, no-op for sync)

When reviewing script changes, verify that:
- No `eval`, `exec`, or command substitution is applied to user-controlled input
- No network calls are made
- File operations stay within declared directories

## Disclosure Expectations

Please give maintainers a reasonable chance to assess and address the issue before broad public write-ups that include exploit details.
