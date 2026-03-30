# Lessons Learned

> Distilled from 8 commits across 2026-03-16 → 2026-03-29
> Evolution: static reference doc → active agent skill → router architecture → per-mode skill registry

## Principles

### 1. Route, don't monolith
A 414-line SKILL.md was unreadable and unmaintainable. Splitting into a router (~250 lines) + detail files (docs/*.md) kept each file focused and made modes independently loadable. When a single file serves multiple consumers, it serves none of them well.

### 2. Match the platform's registration model
/10docs didn't work because Claude Code registers skills by directory name, not by description keywords. The fix was trivial (5 wrapper SKILL.md files + symlinks), but the bug was invisible until tested. Always verify how the host system discovers your extension point — don't assume description-based matching.

### 3. Symlink for single-source-of-truth
Using symlinks (`~/.claude/skills/10docs → project/skills/10docs`) ensures edits to the source repo automatically propagate to the installed skill. No copy, no drift, no sync script.

### 4. Stage the community surface before the feature
GitHub templates, CI checks, CONTRIBUTING.md, and SECURITY.md were updated *before* the v2.1 feature landed. This meant the project looked credible from the first moment anyone discovered it, not after a cleanup pass.

### 5. Hooks enforce what comments suggest
Rule 1 (boundary guard) went from a comment in the doc to a PreToolUse hook that actually blocks out-of-scope edits. Enforcement > documentation. If a rule matters, make it fail loudly when violated.

### 6. Design for the agent's read path, not the human's
The router table, output templates, and anti-pattern table exist because an LLM agent needs structured decision points. A human would prefer prose. When your consumer is an agent, optimize for machine-parseable structure.

### 7. Version semantics signal intent
v1.0 (passive doc) → v2.0 (active agent) → v2.1 (router + DOCS mode). The jump from 1→2 signaled a breaking paradigm shift. 2.0→2.1 signaled additive capability. Naming versions correctly set expectations for consumers.

### 8. Schema must be enforced, not just documented
State file schemas (docs/state-files.md) defined canonical formats, but another project's agent created developer-profile.md with a completely different format. Documentation alone doesn't prevent drift — the reading agent must validate or normalize on read.

### 9. Contract gaps surface at integration, not in isolation
PLAN wrote "Files to touch" but todo.md had no field for it. EXECUTE needed it but couldn't find it. The gap was invisible until both modes ran in sequence. Always trace data across mode boundaries, not just within a single mode.

---

**Formula:** split the monolith, match the platform, symlink the truth, stage the surface, enforce don't suggest, design for your consumer, version your intent, enforce the schema, trace across boundaries.
