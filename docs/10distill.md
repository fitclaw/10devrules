# DISTILL Mode

Extract reusable principles from completed work, and evolve the developer profile.

## Phase 1: Extract L0 Lessons (local)

1. Read `todo.md`, `lessons.md`, and `git log --oneline -20`.
2. Identify repeated moves across the work: what patterns emerged?
3. Convert each repeated move into a named principle:
   - Strip feature names unless needed for clarity.
   - Use action verbs: scope, freeze, sequence, stage, isolate, review, verify.
   - Format: **Principle name** — why it matters.
4. Write output to `lessons.md` or a designated file.
5. End with a one-line summary formula.
6. Output using the distill template in SKILL.md.

## Phase 2: Developer Profile Update

After extracting L0 lessons, update the developer profile.

### Step 1: Read profile

```bash
_PROFILE=~/.10dev/developer-profile.md
_HAS_PROFILE=$([ -f "$_PROFILE" ] && echo "yes" || echo "no")
echo "PROFILE: $_HAS_PROFILE"
```

If no profile exists, skip to Step 3 (Bootstrap).

### Step 2: Compare L0 against profile

For each new L0 lesson extracted in Phase 1:

1. **Keyword match (deterministic)**: Read each blind spot's `Keywords` field. If the L0 lesson text contains 2+ keywords from any blind spot, it's a match.
2. **Agent judgment (fallback)**: If no keyword match, but the agent judges the lesson describes the same category of mistake as an existing blind spot, flag it as a potential match.
3. **On match**:
   - Increment the blind spot's `Frequency` by 1 (once per /10distill run, not per lesson).
   - Update `Last seen` to today's date.
   - Add current project name to `Projects` list (if not already present).
   - Inform the user: "Updated blind spot '{name}': frequency {N-1} → {N}."
4. **On no match but recurring signal**: If the agent judges a lesson could become a recurring pattern (it describes a category of mistake, not a one-off), propose to the user:

```
This lesson looks like it could be a recurring pattern:

  Name: {proposed pattern name}
  Trigger: {when this typically happens}
  Keywords: {suggested keywords}
  Severity: {proposed — MEDIUM by default}

Add to your developer profile?

A) Yes, add it
B) Edit first — let me adjust the name/trigger/keywords
C) Skip — this is project-specific, not a pattern
```

User must confirm (A or B) before any write occurs.

### Step 3: Bootstrap (first-run)

If no profile exists AND Phase 1 produced lessons that look like recurring patterns:

```
I'd like to start tracking your developer patterns.
This creates ~/.10dev/developer-profile.md with your first blind spot entry.

  Name: {proposed pattern name}
  Trigger: {trigger}
  Keywords: {keywords}

Create your developer profile?

A) Yes, create it
B) Skip for now
```

On confirm:
```bash
mkdir -p ~/.10dev
```
Then write the profile file with YAML frontmatter + first entry using the safe write protocol.

### Step 4: Blind spot healing check

For each blind spot in the profile, check if `Last seen` is older than 6 months:

```
Pattern '{name}' hasn't been triggered in 6+ months (last seen: {date}).
This might mean you've overcome it.

A) Downgrade severity (currently {SEVERITY})
B) Remove from profile — I've outgrown this
C) Keep as-is — I just haven't worked on that type of task recently
```

### Step 5: Safe write protocol

All writes to `~/.10dev/developer-profile.md` follow this sequence:

```bash
# 1. Write to temp file
cat > ~/.10dev/developer-profile.md.tmp << 'EOF'
{new file content}
EOF

# 2. Backup current
cp ~/.10dev/developer-profile.md ~/.10dev/developer-profile.md.bak 2>/dev/null

# 3. Atomic move
mv ~/.10dev/developer-profile.md.tmp ~/.10dev/developer-profile.md
```

**Conflict detection**: Before writing, compare the `updated` field in YAML frontmatter against what was read at Step 1. If it changed (another session updated the profile), re-read the file, merge changes (add new entries, take the higher frequency for existing entries), then write again.

### Step 6: Distill diff

After any profile changes, show the user what changed:

```
DEVELOPER PROFILE DIFF:
━━━━━━━━━━━━━━━━━━━━━━
  Updated: {pattern_name} — frequency {N-1} → {N}
  Added:   {new pattern_name} — severity {SEVERITY}
  Healed:  {pattern_name} — downgraded from {OLD} to {NEW}
━━━━━━━━━━━━━━━━━━━━━━
Profile: ~/.10dev/developer-profile.md
```

If no profile changes were made, skip this output.

## Phase 3: Cross-Project Comparison (P2)

This phase activates when `~/.10dev/projects.txt` exists and has 2+ entries.

1. Read `~/.10dev/projects.txt`, take the 10 most recently modified project directories.
2. For each project (excluding current), read the last 50 entries from its `lessons.md`. Skip if directory or file doesn't exist.
3. Compare current L0 lessons against other projects' lessons. If the same *category* of lesson appears in 2+ different projects but is not yet in the profile, propose L1 promotion:

```
Cross-project pattern detected:

  "{lesson A}" in project-alpha (2026-03-15)
  "{lesson B}" in project-beta (2026-03-29)
  Both describe: {category}

Promote to developer profile as a recurring blind spot?

A) Yes, promote to profile
B) Edit first
C) Skip — coincidence, not a pattern
```

4. When an existing L1 blind spot reaches frequency >= 3 across 3+ different projects, propose L2 abstraction:

```
Pattern '{name}' has triggered {N} times across {M} projects.
Ready to abstract into a universal principle?

Proposed L2: "{abstracted principle — project names stripped, action verb format}"

A) Accept this wording
B) Edit the wording
C) Not yet — keep as developer-specific pattern
```

On accept, write to `~/.10dev/universal-principles.md` using the same safe write protocol.

## Phase 4: Profile Export (optional)

When explicitly requested (`/10distill export`):

1. Read `~/.10dev/developer-profile.md`.
2. Generate an anonymized copy:
   - Replace developer name with "Developer"
   - Replace project names with "project-1", "project-2", etc.
   - Keep patterns, triggers, keywords, severity, frequency intact.
3. Write to current project as `developer-principles-export.md`.
4. Inform user: "Exported anonymized profile to `developer-principles-export.md`."
