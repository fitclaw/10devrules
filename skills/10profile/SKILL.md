---
name: 10profile
preamble-tier: 2
description: |
  View and manage your developer profile. Shows blind spots, preferences, progress trajectory.
  Use when asked to "show my profile", "what are my blind spots", "developer profile", or "my patterns".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - AskUserQuestion
---

# 10profile — Developer Profile Viewer

View and manage your developer blind spots, preferences, and progress.

## Preamble (run first)

```bash
source "${CLAUDE_SKILL_DIR}/../../bin/detect-root.sh" 2>/dev/null || {
  _10DEV_ROOT="$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)"
  echo "10DEV_ROOT: ${_10DEV_ROOT}"
}
_HAS_PROFILE=$([ -f ~/.10dev/developer-profile.md ] && echo "yes" || echo "no")
_HAS_PRINCIPLES=$([ -f ~/.10dev/universal-principles.md ] && echo "yes" || echo "no")
_HAS_PROJECTS=$([ -f ~/.10dev/projects.txt ] && echo "yes" || echo "no")
_PROJECT_COUNT=$([ -f ~/.10dev/projects.txt ] && wc -l < ~/.10dev/projects.txt | tr -d ' ' || echo "0")
echo "PROFILE: $_HAS_PROFILE | PRINCIPLES: $_HAS_PRINCIPLES | PROJECTS: $_PROJECT_COUNT"
```

## Procedure

### If no profile exists

```
No developer profile found at ~/.10dev/developer-profile.md.

Your profile gets created automatically when you run /10distill after completing work.
The system detects recurring patterns in your lessons and proposes adding them to your profile.

To get started:
1. Complete some development work
2. Run /10distill to extract lessons
3. The system will propose creating your profile if it finds recurring patterns
```

### If profile exists

1. Read `~/.10dev/developer-profile.md`.
2. If `~/.10dev/universal-principles.md` exists, read it too.
3. Display the profile summary:

```
DEVELOPER PROFILE: {developer name}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Last updated: {date} | Patterns tracked: {pattern_count}
Projects: {project_count} registered

## Blind Spots ({count})

  ⚠ HIGH ({count}):
    • {name} — triggered {N} times across {M} projects
      Last seen: {date} | Defense: {defense}

  MEDIUM ({count}):
    • {name} — triggered {N} times across {M} projects
      Last seen: {date} | Defense: {defense}

  LOW ({count}):
    • {name} — triggered {N} times
      Last seen: {date}

## Preferences ({count})
    • {preference description}

## Progress
    Patterns healed (6+ months quiet): {count}
    Patterns worsening (frequency rising): {count}
    Newest pattern: {name} (added {date})

## Universal Principles ({count}, if any)
    • {principle}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

4. Offer management actions:

```
What would you like to do?

A) Done — just viewing
B) Edit a blind spot (change severity, keywords, or trigger)
C) Remove a blind spot
D) Export anonymized profile
```

If B: ask which blind spot, then present current values and let user modify.
If C: confirm removal, then update profile using safe write protocol from docs/10distill.md.
If D: run the export procedure from docs/10distill.md Phase 4.
