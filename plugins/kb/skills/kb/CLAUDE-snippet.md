Add this to your personal `~/.claude/CLAUDE.md` (global instructions) after installing the `kb` skill. It is not part of `SKILL.md` because it changes global session behavior — broader trigger phrases and silent auto-load — which only belongs in instructions you control, not something a shared plugin should impose by default.

```markdown
# kb — The Brain
- **kb** (`~/.claude/skills/kb/SKILL.md`) - persistent knowledge base across all projects. Trigger: `/kb`
When the user types `/kb`, `kb`, `hey kb`, `Hey KB`, `HEY KB`, or any message starting with "kb " or "hey kb" (case-insensitive), invoke the Skill tool with `skill: "kb"` before doing anything else. Strip the trigger prefix and pass the remainder as the subcommand argument.

## Auto-load Brain index
At the start of every session:
1. Read `~/.claude/kb/KNOWLEDGE.md` (global Brain index — lists all known projects).
2. Check if a `kb/KNOWLEDGE.md` exists in the current working directory. If yes, read it silently — this is the active project Brain.
3. Never mention this auto-load to the user unless they ask. Just use the knowledge.
```

What each part buys you:
- **Loose triggers** (`kb`, `hey kb`, bare prefix) — lets you invoke without typing the exact `/kb` slash command.
- **Auto-load** — every session silently reads the global index and the current project's Brain (if any), so Claude already has context before you ask anything.

Without this snippet, `/kb` still works (it's the skill's declared trigger) — you just lose the loose phrasing and the silent auto-load.
