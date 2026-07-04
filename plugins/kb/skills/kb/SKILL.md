---
name: kb
description: The Brain — persistent knowledge base that grows with every project. Remembers architecture, patterns, decisions, and history across all sessions.
trigger: /kb
---

# /kb — The Brain

A persistent, structured knowledge base that helps AI never forget context across sessions. Grows as projects grow. Covers all projects system-wide.

## Usage

```
/kb                        # show Brain status for current project
/kb init                   # first-time setup: create kb/ folder + ingest project files
/kb learn                  # read current project state → write brain dump to sessions/
/kb add <topic>            # add new knowledge doc (prompts for content)
/kb update <doc>           # update existing doc
/kb search <query>         # find relevant docs by keyword/topic
/kb list                   # list all docs in current project KB
/kb sync                   # register current project in global Brain index
/kb decision <title>       # log an architecture decision record (ADR)
/kb fail <topic>           # log what failed + why (anti-pattern)
```

---

## What You Must Do When Invoked

Read the command the user typed after `/kb`. If no subcommand given, run the default status check (Step 0).

---

## Step 0 — Default: Brain Status

If user types just `/kb`:

1. Check if `kb/` exists in the current working directory.
2. If **no `kb/` folder**: print:
   ```
   Brain not initialized for this project.
   Run /kb init to set up the Brain here.
   ```
   Stop.
3. If **`kb/` exists**: read `kb/KNOWLEDGE.md` and print a summary:
   ```
   Brain active for: {project name from cwd}
   Docs indexed: {count from KNOWLEDGE.md}
   Last updated: {date from most recent file}
   
   Topics covered:
   {list doc names + one-line descriptions from KNOWLEDGE.md index}
   ```

---

## Step 1 — `/kb init`

First-time setup for the current project.

### 1A — Check if already initialized

Check whether `kb/KNOWLEDGE.md` exists in the current working directory. If it does, print:

```
Brain already initialized. Use /kb learn to update from current project state.
```

Then stop.

### 1B — Create folder structure

Create these directories (use whatever shell fits the platform — `mkdir -p` on macOS/Linux, `New-Item -ItemType Directory -Force` on Windows PowerShell):

```
kb/
kb/decisions/
kb/sessions/
kb/domains/
```

### 1C — Scan project files

Read the current directory. Identify:
- Code files (`.py`, `.ts`, `.js`, `.tsx`, `.go`, `.rs`, `.java`, `.cs`, `.cpp`, `.rb`)
- Config files (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `*.yaml`, `*.json`)
- Docs (`README.md`, `*.md`, `CLAUDE.md`)
- Ignore: `node_modules/`, `.git/`, `__pycache__/`, `dist/`, `build/`, `kb/`

Print file count summary before proceeding.

### 1D — Build initial knowledge docs

Read the scanned files and synthesize the following docs. Write each one to disk.

**`kb/KNOWLEDGE.md`** — master index (keep under 100 lines):
```markdown
---
project: {project name}
created: {today's date}
last-updated: {today's date}
---

# Brain Index — {project name}

## Quick Facts
- **What it is:** {one sentence}
- **Stack:** {languages/frameworks detected}
- **Entry points:** {main files}

## Docs
| Doc | Topic | Status |
|-----|-------|--------|
| [architecture.md](architecture.md) | How it's built, key components | active |
| [patterns.md](patterns.md) | Code conventions and patterns | active |
| [anti-patterns.md](anti-patterns.md) | What to avoid + why | active |
| [domains/](domains/) | Business rules and domain knowledge | active |
| [decisions/](decisions/) | Architecture decisions (ADRs) | active |
| [sessions/](sessions/) | Session brain dumps | active |

## Cross-links
{list any domain docs created}
```

**`kb/architecture.md`** — synthesize from reading the codebase:
```markdown
---
project: {name}
confidence: medium
last-verified: {today}
status: active
---

# Architecture

## What it does
{1-2 sentences}

## Key components
{list main modules/files with one-line purpose each}

## Data flow
{describe how data moves through the system}

## External dependencies
{list major deps and what they're used for}

## Entry points
{main files, scripts, or commands to run the project}
```

**`kb/patterns.md`** — extract from reading code files:
```markdown
---
project: {name}
confidence: medium
last-verified: {today}
status: active
---

# Code Patterns

## Conventions
{naming conventions, file structure patterns}

## How to add a new {main abstraction}
{step-by-step pattern}

## Common patterns in this codebase
{list patterns with examples}

## Testing approach
{how tests are written here}
```

**`kb/anti-patterns.md`** — start minimal, grow over time:
```markdown
---
project: {name}
confidence: high
last-verified: {today}
status: active
---

# Anti-Patterns — What NOT to Do

{If you detect obvious anti-patterns from code, list them.
Otherwise write:}

## No anti-patterns logged yet.
Run /kb fail <topic> to log something that failed and why.
```

### 1E — Register in global Brain index

Update `~/.claude/kb/KNOWLEDGE.md` (create the file and its parent directory if they don't exist yet) — add an entry for this project:
```markdown
| [{project name}]({absolute path to kb/KNOWLEDGE.md}) | {stack} | {today} |
```

### 1F — Report

Print:
```
Brain initialized for: {project name}
Created:
  kb/KNOWLEDGE.md       ← master index
  kb/architecture.md    ← {N} components mapped
  kb/patterns.md        ← patterns extracted
  kb/anti-patterns.md   ← ready for failures

Files scanned: {N}
Run /kb learn after complex sessions to capture what the AI learned.
```

---

## Step 2 — `/kb learn`

Read current project state → write a brain dump session doc.

### 2A — Gather context

Read these files in order (skip missing ones):
1. `kb/KNOWLEDGE.md` — what Brain already knows
2. `kb/architecture.md`
3. `kb/patterns.md`
4. Last 3 files in `kb/sessions/` (sorted by date, newest first)
5. Recent files modified in the project (check git log if available: `git log --oneline -10`)

### 2B — Write brain dump

Create `kb/sessions/{YYYY-MM-DD}.md`. If that file already exists (an earlier session today already dumped), do NOT overwrite it — append a separator line `---` followed by a new `# Session Brain Dump — {today} {HH:MM}` section with the same structure below:

```markdown
---
date: {today}
type: session-brain-dump
confidence: high
status: active
---

# Session Brain Dump — {today}

## What was worked on
{1-3 sentences}

## Key decisions made this session
{bullet list — each decision gets a one-liner: what + why}

## What AI learned that isn't in docs yet
{bullet list — new patterns, gotchas, conventions discovered}

## Errors hit + how they were fixed
{table: error → root cause → fix}

## State of the project right now
{1 paragraph — what's done, what's in progress, what's next}

## Cross-links
{[[architecture]], [[patterns]], [[decisions/xxx]] as relevant}
```

If any decision is significant enough, also run Step 5 (`/kb decision`) automatically.

### 2C — Update KNOWLEDGE.md last-updated date

Edit `kb/KNOWLEDGE.md` frontmatter: `last-updated: {today}`.

Print:
```
Brain dump written: kb/sessions/{today}.md
```

---

## Step 3 — `/kb add <topic>`

Add a new knowledge doc.

1. Determine the right folder:
   - Business rule / domain concept → `kb/domains/{topic}.md`
   - Code pattern → append to `kb/patterns.md`
   - General doc → `kb/topic.md`

2. Write the doc using this template:
```markdown
---
topic: {topic}
created: {today}
confidence: high
status: active
---

# {Topic}

{Content the user provided or that AI synthesizes from current project context}

## Cross-links
{[[related-docs]]}
```

3. Add entry to `kb/KNOWLEDGE.md` index table.

4. Print: `Added: kb/{path}`

---

## Step 4 — `/kb update <doc>`

1. Find the doc (search `kb/` for filename match).
2. Read current content.
3. Ask user what to update, or if context makes it obvious, update directly.
4. Preserve frontmatter. Update `last-verified: {today}`.
5. Print diff summary of what changed.

---

## Step 5 — `/kb decision <title>`

Log an Architecture Decision Record.

Create `kb/decisions/{YYYY-MM-DD}-{slug}.md`:

```markdown
---
title: {title}
date: {today}
status: accepted
---

# Decision: {title}

## Context
{What situation forced this decision}

## Decision
{What was decided}

## Why
{Reasoning — constraints, tradeoffs, alternatives rejected}

## Consequences
{What this means going forward — what gets easier, what gets harder}

## Alternatives rejected
| Alternative | Why rejected |
|-------------|--------------|
| {alt} | {reason} |
```

Add to `kb/KNOWLEDGE.md` decisions section.

---

## Step 6 — `/kb fail <topic>`

Log what failed and why — the most valuable memory.

Append to `kb/anti-patterns.md`:

```markdown
## {Topic} — {today}

**What failed:** {description}
**Root cause:** {why it failed}
**How we fixed it:** {fix}
**Never do this because:** {the hard lesson}
**Watch for:** {warning signs this is happening again}
```

---

## Step 7 — `/kb search <query>`

1. Read `kb/KNOWLEDGE.md` index.
2. Scan doc filenames and descriptions for keyword matches.
3. Read matching docs (top 3 most relevant).
4. Return synthesized answer with citations to source docs.

Format:
```
Found in Brain:

[kb/architecture.md] — {relevant excerpt}
[kb/patterns.md] — {relevant excerpt}

Summary: {synthesized answer}
```

---

## Step 8 — `/kb list`

Read `kb/KNOWLEDGE.md`. Print the doc table plus:
- Session count (files in `kb/sessions/`)
- Decision count (files in `kb/decisions/`)
- Domain doc count (files in `kb/domains/`)

---

## Step 9 — `/kb sync`

Register/update current project in global Brain:

Read `~/.claude/kb/KNOWLEDGE.md` (create the file and its parent directory if they don't exist yet).
Find existing entry for this project path (if any).
Update or add:
- Project name
- Path to `kb/KNOWLEDGE.md`
- Stack
- Last updated date

Print: `Global Brain updated. This project now indexed.`

---

## Staleness Rules

- `confidence: high` + `last-verified` > 30 days ago → warn "may be stale, verify before trusting"
- `status: stale` → always warn before using
- `status: superseded-by: [[new-doc]]` → redirect to new doc

When reading KB docs to answer a question, always check `last-verified` date. If older than 30 days, verify against current code before asserting.

---

## Cross-linking

Use `[[doc-name]]` to link between docs. Examples:
- `[[architecture]]` → links to `kb/architecture.md`
- `[[decisions/2026-06-20-use-jwt]]` → links to a decision
- `[[domains/auth]]` → links to a domain doc

When writing any doc, always add a `## Cross-links` section at the bottom.

---

## Growth Rule

The Brain grows in two ways:
1. **`/kb learn`** — after complex sessions
2. **`/kb add`, `/kb decision`, `/kb fail`** — when user explicitly feeds it

Never auto-write to KB mid-session without user triggering it. Always confirm before writing.
