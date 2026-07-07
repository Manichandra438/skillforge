# skillforge

A growing collection of [Claude Code](https://claude.com/claude-code) / [Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills) skills. Each skill is its own independently installable plugin — installing one does not pull in the others.

## Skills included

| Skill | Trigger | Install | What it does |
|-------|---------|---------|---------------|
| [`kb`](plugins/kb/skills/kb/SKILL.md) (knowledge base) | `/kb` | `/plugin install kb@skillforge` or `install-kb.sh` | **The Brain** — a persistent, structured knowledge base per project. Tracks architecture, code patterns, anti-patterns, decisions (ADRs), and session-by-session brain dumps, so Claude never starts from zero on a project it has seen before. |

More skills will be added here over time, each with its own row, its own entry in `plugins/`, and its own `install-<skill>.sh` / `install-<skill>.ps1`. See [CONTRIBUTING.md](CONTRIBUTING.md) if you want to add one.

## Install `kb` (knowledge base)

### Claude Code (plugin marketplace)

```
/plugin marketplace add Manichandra438/skillforge
/plugin install kb@skillforge
```

Only `kb` is installed — other skills in this marketplace (once added) need their own `/plugin install <skill>@skillforge`.

### One-line install (Claude Code + GitHub Copilot CLI)

```bash
curl -fsSL https://raw.githubusercontent.com/Manichandra438/skillforge/main/install-kb.sh | bash
```

```powershell
irm https://raw.githubusercontent.com/Manichandra438/skillforge/main/install-kb.ps1 | iex
```

Installs `kb` for **Claude Code** (`~/.claude/skills/kb/`, global — every project) and, if run from inside a repo, for **Copilot CLI** (`.github/skills/kb/`, that repo only — [Copilot skills are repo-scoped](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills)). This script only ever touches `kb` — it never installs other skillforge skills.

Flags: `--claude-only`, `--copilot-only`, `--dir <path>` (target repo for the Copilot install, defaults to `.`). Same flags work on the PowerShell script (`-ClaudeOnly`, `-CopilotOnly`, `-Dir`).

### Optional: loose triggers + auto-load for `/kb`

By default the skill responds to the `/kb` slash command. If you also want it to trigger on bare `kb`, `hey kb`, etc., and to silently auto-load the Brain index at the start of every session, copy the snippet in [`plugins/kb/skills/kb/CLAUDE-snippet.md`](plugins/kb/skills/kb/CLAUDE-snippet.md) into your personal `~/.claude/CLAUDE.md`. This is opt-in and lives in your own instructions, not the shared plugin, since it changes global session behavior.

## Using `/kb` (knowledge base)

### Quickstart

```
cd your-project
/kb init
```
Scans the project, creates `kb/` with `KNOWLEDGE.md`, `architecture.md`, `patterns.md`, `anti-patterns.md`.

Work normally for a while, then close out the session:
```
/kb learn
```
Writes `kb/sessions/{today}.md` — what got worked on, decisions made, errors hit + fixes, current state.

Next session, just ask:
```
/kb search how does auth work here
```
Claude reads `kb/`, cites the relevant docs, answers from what it already knows about this project.

### All commands

| Command | What it does |
|---------|---------------|
| `/kb` | Show Brain status for current project (docs indexed, last updated) |
| `/kb init` | First-time setup: scan project, create `kb/` folder + initial docs |
| `/kb learn` | Read current project state → write a session brain dump |
| `/kb add <topic>` | Add a new knowledge doc |
| `/kb update <doc>` | Update an existing doc |
| `/kb search <query>` | Find relevant docs by keyword/topic, answer with citations |
| `/kb list` | List all docs in the project's KB |
| `/kb sync` | Register current project in the global Brain index |
| `/kb decision <title>` | Log an architecture decision record (ADR) |
| `/kb fail <topic>` | Log what failed and why (anti-pattern) |

### How the data is organized

Each project gets its own `kb/` folder:

```
kb/
  KNOWLEDGE.md      # master index — read this first
  architecture.md   # how it's built, key components, data flow
  patterns.md       # code conventions, how to add things
  anti-patterns.md  # what failed before and why
  decisions/        # one file per ADR
  sessions/         # one brain dump per session
  domains/          # business rules, domain concepts
```

A global index at `~/.claude/kb/KNOWLEDGE.md` tracks every project that has run `/kb init` or `/kb sync`, so Claude can find any project's Brain from anywhere. Nothing is written to `kb/` automatically mid-session — every write is triggered by you running one of the commands above.

## Repo layout

```
.claude-plugin/
  marketplace.json         # marketplace manifest — lists each skill as its own plugin
docs/
  ENGINEERING_GUIDELINES.md # language-agnostic engineering standards
plugins/
  kb/
    .claude-plugin/
      plugin.json           # kb's own plugin manifest
    skills/
      kb/
        SKILL.md            # the kb skill definition
        CLAUDE-snippet.md   # optional CLAUDE.md additions (loose triggers + auto-load)
install-kb.sh               # one-line installer (bash) — kb only
install-kb.ps1               # one-line installer (PowerShell) — kb only
```

Future skills follow the same pattern: `plugins/<skill>/`, a new entry in `marketplace.json`, and their own `install-<skill>.sh` / `.ps1`.

## Docs

- [`docs/ENGINEERING_GUIDELINES.md`](docs/ENGINEERING_GUIDELINES.md) — language-agnostic engineering standards (architecture, testing, security, git, review, etc.). Reference it from a project's `CLAUDE.md` so Claude follows it when writing or reviewing code.

## License

MIT — see [LICENSE](LICENSE).
