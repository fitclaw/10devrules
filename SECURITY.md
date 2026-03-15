# Security Policy

Although this repository is documentation-first and does not ship a hosted service, security concerns can still exist.

Examples include:

- Prompt injection patterns hidden in examples or instructions
- Unsafe guidance that could cause destructive actions in downstream use
- Accidental inclusion of secrets, personal data, or private references
- Malicious links or untrusted external dependencies added to documentation

## How To Report

If you find a security issue:

1. Prefer GitHub's private reporting or security advisory flow when available.
2. If private reporting is not available, open a minimally detailed public issue.
3. Avoid posting secrets, tokens, credentials, private URLs, or exploit-ready payloads in public.

## What To Include

Please include:

- A short description of the problem
- The affected file or section
- Why the issue matters
- Safe reproduction steps, if applicable
- A suggested fix, if you have one

## Response Guidelines

Maintainers should aim to:

- Acknowledge the report
- Triage impact and scope
- Remove sensitive material quickly if it was posted accidentally
- Ship a fix or mitigation in the smallest safe change

## Disclosure Expectations

Please give maintainers a reasonable chance to assess and address the issue before broad public write-ups that include exploit details.
