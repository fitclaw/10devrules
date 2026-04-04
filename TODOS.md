# TODOS

## Schema validation on profile read

**What:** Add format validation when reading `~/.10dev/developer-profile.md`. Check YAML frontmatter required fields (`developer`, `updated`, `version`, `pattern_count`) and blind spot entry required fields (`Keywords`, `Trigger`, `Frequency`, `Severity`).

**Why:** The project's own lessons.md #8 states "Schema must be enforced, not just documented." Current malformed handling only catches YAML parse failures, not missing/invalid fields. Other tools or manual edits could produce a syntactically valid but semantically incomplete profile.

**Pros:** Prevents silent failures when profile is incomplete. Catches issues early with clear error messages.

**Cons:** Requires defining "valid" strictly. May break forward/backward compatibility if schema evolves. Agent-driven validation adds complexity to prompt instructions.

**Context:** Identified during eng review (2026-04-04). The profile format is defined in `docs/state-files.md`. Current malformed handling is in design doc section "Malformed profile handling" (check .bak, skip corrupt files). The gap is between "YAML parses" and "all required fields present."

**Depends on:** Stable profile format (current schema in state-files.md).
