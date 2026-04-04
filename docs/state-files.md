# State File Schemas

Canonical formats for all state files used by 10devrules. Every reader/writer must follow these schemas.

---

## Local State Files (per-project)

### todo.md

```markdown
# Task Plan

## Stages
- [ ] Stage 1: {name} | Entry: {condition} | Exit: {condition} | Files: {path1, path2}
- [ ] Stage 2: {name} | Entry: {condition} | Exit: {condition} | Files: {path3}
- [x] Stage 3: {name} | Entry: {condition} | Exit: {condition} | Files: {path4, path5}
```

The `Files:` field lists predicted files to touch (comma-separated). EXECUTE uses this to flag drift when the diff touches unexpected files. If a stage has no `Files:` field (legacy format), EXECUTE skips the file drift check for that stage.

Created by: PLAN Phase 4. Updated by: EXECUTE (checkbox toggling).

### .10dev/boundary.txt

One allowed edit path per line (relative to project root):

```
src/
tests/
docs/
```

Created by: PLAN Phase 1. Read by: `bin/check-boundary.sh` hook.

### .10dev/contract.md

```markdown
# Frozen Contracts — {task name}

## Types/Interfaces
- UserService.create(params: CreateUserParams): Promise<User>

## API Surface
- POST /api/users — creates user, returns 201

## Schema
- users table: add column `avatar_url` (nullable varchar)

## Acceptance Criteria
- User can sign up with email + password
- Avatar upload works for PNG/JPG under 5MB
```

Created by: PLAN Phase 2.

### lessons.md

```markdown
# Lessons Learned

> Distilled from {N} commits across {date range}

## Principles

### 1. {Principle name}
{Why it matters. One paragraph.}

### 2. {Principle name}
{Why it matters.}

---

**Formula:** {one-line summary using action verbs}
```

Created by: DISTILL Phase 1. Updated by: subsequent DISTILL runs.

### .10dev/doc-sync.yaml

```yaml
vault_root: ~/dev-vault
project_name: auto
staleness_threshold_days: 7
auto_archive_on_phase_complete: false
sync_on_mode_transition: true
```

Created by: DOCS first-run setup.

---

## Global State Files (~/.10dev/)

### ~/.10dev/developer-profile.md

```markdown
---
developer: vtx
updated: 2026-03-30T15:42:00
version: 1
pattern_count: 2
---

## Blind Spots

- **Assumes platform behavior** | Frequency: 3 | Severity: HIGH
  Keywords: platform, registration, discovery, plugin, extension, skill
  Trigger: Developing plugins, extensions, skills, or integrations for a host platform
  Typical error: Does not test how the host system discovers/registers the extension
  Defense: In PLAN phase, add a task: "Verify {platform}'s extension discovery mechanism"
  Last seen: 2026-03-29 | Projects: 10devrules, unity-mcp-skill, obsidian-plugin

- **Skips failure path design** | Frequency: 2 | Severity: MEDIUM
  Keywords: failure, error, edge case, unhappy path, exception, fallback
  Trigger: Feature development enters "excitement" phase, happy path is working
  Typical error: Only designs happy path, ignores edge cases and error states
  Defense: In PLAN phase, Rule 7 gate: enumerate unhappy paths per stage
  Last seen: 2026-03-28 | Projects: 10devrules, api-gateway

## Preferences (validated habits)

- Symlinks over copy for single-source-of-truth — confirmed in 10devrules, dotfiles
```

Created by: DISTILL Phase 2 (bootstrap). Updated by: DISTILL (frequency/severity changes). Managed by: /10profile.

**Field rules:**
- `Frequency`: increments once per /10distill run, not per matching lesson
- `Severity`: HIGH (>2h rework), MEDIUM (<2h wasted), LOW (minor friction)
- `Keywords`: agent uses for deterministic matching before falling back to judgment
- `Projects`: list of project names where this pattern was observed

### ~/.10dev/universal-principles.md

```markdown
# Universal Principles (L2)

Abstracted from developer-specific patterns. Project-independent.

- **Verify host discovery before building extensions** — Abstracted from "Assumes platform behavior" (3 projects). Always test how the host system finds your plugin/extension before writing code.

- **Enumerate failure paths before implementation** — Abstracted from "Skips failure path design" (3 projects). List every unhappy path per stage before writing the happy path.
```

Created by: DISTILL Phase 3 (L1→L2 promotion). Read by: PLAN Phase 0.

### ~/.10dev/projects.txt

One absolute project path per line:

```
/Users/vtx/LocalProjects/10dev
/Users/vtx/LocalProjects/api-gateway
/Users/vtx/LocalProjects/obsidian-plugin
```

Created by: PLAN Phase 0 (auto-appended, deduped). Read by: DISTILL Phase 3 (cross-project comparison, limited to 10 most recently modified).

### ~/.10dev/.onboarded

Empty sentinel file. Existence means global onboarding completed.

### ~/.10dev/.routing_declined

Empty sentinel file. Existence means user declined CLAUDE.md routing injection.
