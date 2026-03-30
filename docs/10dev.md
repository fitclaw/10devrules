# /10dev — Orchestrator Entry Point

Environment manager and onboarding orchestrator for 10 Development Rules. Does NOT own any state files. Detects current state, guides the user, then delegates to existing skills.

## Flow Router

```
ONBOARDED=no?
  → Phase 1 (welcome) → Phase 2 (CLAUDE.md) → Phase 3 (project scan) → Phase 4 (launch skill)
  → touch ~/.10dev/.onboarded

ONBOARDED=yes, PROJECT_10DEV=no?
  → Phase 3 (project scan) → Phase 4 (launch skill)

ONBOARDED=yes, PROJECT_10DEV=yes?
  → Phase 5 (dashboard)

Subcommand "/10dev setup"?
  → rm ~/.10dev/.onboarded → restart from Phase 1

Subcommand "/10dev status"?
  → Phase 5 (dashboard) regardless of state
```

---

## Phase 1: Welcome (runs once globally)

Display:

```
10 DEVELOPMENT RULES
━━━━━━━━━━━━━━━━━━━━

A Claude Code agent skill. 10 rules as active decision gates.

Workflow: plan → exec → review → distill
          scope → build → audit → learn

Commands:
  /10plan    Scope boundaries, contracts, stages, failure paths
  /10exec    Staged execution + isolation + self-correction
  /10review  10-rule audit (SHIP / BLOCK verdict)
  /10distill Extract principles + evolve developer profile
  /10docs    Document health + Obsidian vault sync
  /10profile View/manage your blind spot profile
  /10dev     This command — environment + status

Typical first session: /10plan → /10exec → /10review → /10distill
━━━━━━━━━━━━━━━━━━━━
```

No configuration questions. Welcome is informational only. Proceed to Phase 2.

---

## Phase 2: CLAUDE.md Routing Injection

**Condition:** `ROUTING=no` AND `ROUTING_DECLINED=no`

Ask:

```
10dev can add routing rules to this project's CLAUDE.md.
Effect: say "help me plan this feature" → auto-triggers /10plan.

A) Add routing rules (recommended)
B) No thanks, I'll type /10xxx commands manually
```

**If A:**
1. Create CLAUDE.md if it doesn't exist.
2. Check idempotency: `grep -q "## Skill routing — 10dev" CLAUDE.md`. If found, skip.
3. Append routing block:

```markdown

## Skill routing — 10dev

When the user's request matches a 10dev mode, invoke the corresponding skill
as your FIRST action. Do NOT answer directly.

- "plan", "scope", "design", "start a task" → invoke 10plan
- "build", "implement", "execute", "code this" → invoke 10exec
- "review", "audit", "check", "PR review" → invoke 10review
- "distill", "retro", "what did we learn" → invoke 10distill
- "sync docs", "doc health", "clean up docs" → invoke 10docs
- "my profile", "blind spots" → invoke 10profile
- "10dev", "status" → invoke ten-dev-rules
```

4. Tell the user: "Routing rules added to CLAUDE.md. You can commit it when ready: `git add CLAUDE.md && git commit -m 'chore: add 10dev routing rules'`"

Do NOT auto-commit. The user controls when to commit project files.

**If B:**
```bash
mkdir -p ~/.10dev
touch ~/.10dev/.routing_declined
```

---

## Phase 3: Project Scan

**Condition:** `PROJECT_10DEV=no` (project hasn't used 10dev before)

### Step 1: Lightweight scan

```bash
_PROJECT_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null || pwd)")
_COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
_LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "none")
_HAS_README=$([ -f README.md ] && echo "✓" || echo "✗")
_HAS_CLAUDE_MD=$([ -f CLAUDE.md ] && echo "✓" || echo "✗")
```

Display:

```
New project detected: {name}
Branch: {branch} | Commits: {N} | Last: {last commit}

Docs: README {✓/✗}  CLAUDE.md {✓/✗}  todo.md {✓/✗}  lessons.md {✓/✗}
Profile: {✓ N blind spots / ✗ not created yet}
```

### Step 2: Read context (lightweight)

Read existing docs to understand the project (agent reads, does not display raw content):
- `README.md` (first 100 lines, if exists)
- `CLAUDE.md` (if exists)
- `git log --oneline -10`

Generate a one-line project summary: "This appears to be a {type} that {does what}."

### Step 3: Create .10dev/

```bash
mkdir -p .10dev
```

That's it. No boundary.txt, no lessons.md, no projects.txt registration. Each skill creates its own state when the user actually uses it.

---

## Phase 4: Launch First Skill

Ask:

```
Environment ready. What would you like to do first?

A) /10plan — Plan a new feature (creates boundary, contracts, stages)
B) /10review — Audit recent code changes against 10 rules
C) /10distill — Extract lessons from completed work (creates developer profile)
D) Explore on my own — don't launch anything
```

**If A/B/C:** Read the corresponding skill's SKILL.md from `{10DEV_ROOT}/skills/{choice}/SKILL.md` and execute it inline. Skip the chosen skill's preamble sections that /10dev already handled (state detection, project context).

**If D:** Display available commands and exit.

---

## Phase 5: Dashboard

**Condition:** `ONBOARDED=yes` AND `PROJECT_10DEV=yes`

Run status detection:

```bash
# Count todo items
_TODO_PENDING=0; _TODO_DONE=0
if [ -f todo.md ]; then
  _TODO_PENDING=$(grep -c '^\- \[ \]' todo.md 2>/dev/null || echo "0")
  _TODO_DONE=$(grep -c '^\- \[x\]' todo.md 2>/dev/null || echo "0")
fi

# Count lessons
_LESSON_COUNT=0
[ -f lessons.md ] && _LESSON_COUNT=$(grep -c '^### \|^- \*\*' lessons.md 2>/dev/null || echo "0")

# Count boundary paths
_BOUNDARY_COUNT=0
[ -f .10dev/boundary.txt ] && _BOUNDARY_COUNT=$(wc -l < .10dev/boundary.txt | tr -d ' ')

# Count profile blind spots
_BLIND_SPOTS=0
[ -f ~/.10dev/developer-profile.md ] && _BLIND_SPOTS=$(grep -c '^\- \*\*' ~/.10dev/developer-profile.md 2>/dev/null || echo "0")

# Count principles
_PRINCIPLES=0
[ -f ~/.10dev/universal-principles.md ] && _PRINCIPLES=$(grep -c '^\- \|^### ' ~/.10dev/universal-principles.md 2>/dev/null || echo "0")

# Count registered projects
_REG_PROJECTS=0
[ -f ~/.10dev/projects.txt ] && _REG_PROJECTS=$(wc -l < ~/.10dev/projects.txt | tr -d ' ')
```

Display:

```
10 DEV RULES: STATUS
━━━━━━━━━━━━━━━━━━━━
Project: {name} | Branch: {branch}

Local:
  .10dev/boundary.txt   {✓ N paths / ✗ not set}
  .10dev/contract.md    {✓ frozen / ✗ not set}
  todo.md               {✓ N pending, N done / ✗ not created}
  lessons.md            {✓ N entries / ✗ not created}

Global:
  Developer profile     {✓ N blind spots / ✗ not created}
  Projects registered   {N}
  Universal principles  {✓ N / ✗ none yet}

CLAUDE.md routing       {✓ active / ✗ not configured}
━━━━━━━━━━━━━━━━━━━━
```

**Smart suggestion** based on state:
- boundary ✗ + todo ✗ → "Suggestion: run /10plan to scope your next task."
- todo has all items done → "Suggestion: run /10review then /10distill."
- lessons ✓ but profile ✗ → "Suggestion: run /10distill to create your developer profile."
- Everything ✓ → "All set. Run /10plan when you're ready for the next task."
