# Security Policy

This repository ships an AI agent skill (`SKILL.md`) and an optional shell hook (`bin/check-boundary.sh`). While it does not run a hosted service, security concerns can still exist.

## Threat Surface

| Area | Risk |
|------|------|
| **Prompt injection** | Malicious examples or instructions hidden in the skill that trick an AI agent into destructive actions |
| **Hook script** | `check-boundary.sh` runs as a PreToolUse hook — a compromised version could suppress warnings or exfiltrate file paths |
| **Unsafe guidance** | Rules or examples that could cause data loss, credential exposure, or destructive commands in downstream use |
| **Data leaks** | Accidental inclusion of secrets, personal data, or private references in any file |
| **Malicious links** | Untrusted external URLs added to documentation or examples |

## How To Report

If you find a security issue:

1. **Prefer GitHub's private reporting** or security advisory flow when available.
2. If private reporting is not available, open a minimally detailed public issue.
3. **Never post** secrets, tokens, credentials, private URLs, or exploit-ready payloads in public.

## What To Include

- A short description of the problem
- The affected file or section (e.g., `SKILL.md` line 42, `bin/check-boundary.sh`)
- Why the issue matters (what could go wrong in real use)
- Safe reproduction steps, if applicable
- A suggested fix, if you have one

## Response Guidelines

Maintainers should aim to:

- Acknowledge the report promptly
- Triage impact and scope
- Remove sensitive material quickly if posted accidentally
- Ship a fix in the smallest safe change

## Hook Script Security

The `bin/check-boundary.sh` hook:

- Reads JSON from stdin and extracts `file_path`
- Reads `.10dev/boundary.txt` for allowed paths
- Returns `permissionDecision: "ask"` (advisory) for out-of-scope edits
- Does NOT execute any commands from the JSON input
- Does NOT transmit data to external services
- Falls back to allowing edits if parsing fails (fail-open, not fail-closed)

When reviewing hook changes, verify that:
- No `eval`, `exec`, or command substitution is applied to user-controlled input
- No network calls are made
- The fail-open behavior is preserved

## Disclosure Expectations

Please give maintainers a reasonable chance to assess and address the issue before broad public write-ups that include exploit details.
