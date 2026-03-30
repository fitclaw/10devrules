# Security Policy

This repository ships an AI agent skill (`SKILL.md`), mode detail files (`docs/`), slash command wrappers (`skills/`), and shell scripts (`bin/`). While it does not run a hosted service, security concerns can still exist.

## Threat Surface

| Area | Risk |
|------|------|
| **Prompt injection** | Malicious instructions hidden in skill files that trick an AI agent into destructive actions |
| **Hook scripts** | `check-boundary.sh` runs as a PreToolUse hook — a compromised version could suppress warnings or exfiltrate file paths |
| **Doc sync scripts** | `doc-sync.sh` writes files to the Obsidian vault — a compromised version could overwrite unrelated files |
| **Developer profile** | `~/.10dev/developer-profile.md` contains blind spot history — a compromised /10distill could inject false patterns or read cross-project data |
| **Global state** | `~/.10dev/projects.txt` lists all project paths — leaking this reveals the developer's project inventory |
| **Safe write protocol** | The .tmp -> .bak -> mv sequence could be exploited if an attacker controls the temp file |
| **CLAUDE.md injection** | `/10dev` modifies CLAUDE.md — a compromised version could inject malicious routing rules |
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
- The affected file or section (e.g., `SKILL.md`, `docs/10distill.md`, `bin/doc-sync.sh`, `skills/10dev/SKILL.md`)
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
- Use directory-safe path matching (require `/` separator, not prefix matching)
- Fall back to safe defaults if parsing fails (fail-open for boundary check, no-op for sync)

## Global State Security

Files in `~/.10dev/`:

- Written only by the agent following documented procedures
- Use safe write protocol: write to `.tmp` -> backup to `.bak` -> atomic `mv`
- Conflict detection via `updated` timestamp comparison
- No network access, no external service calls
- Developer profile contains behavioral patterns, not credentials or secrets

When reviewing changes that touch global state, verify that:
- No arbitrary file paths are written outside `~/.10dev/`
- The safe write protocol is followed
- Conflict detection logic is preserved
- No profile data is transmitted externally

## Disclosure Expectations

Please give maintainers a reasonable chance to assess and address the issue before broad public write-ups that include exploit details.
