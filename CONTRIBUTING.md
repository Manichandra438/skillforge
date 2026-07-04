# Contributing

skillforge is a collection repo — one marketplace, many independently installable plugins (one per skill). Installing one skill never pulls in another. PRs adding new skills are welcome.

## Adding a new skill

1. Create a self-contained plugin dir: `plugins/<your-skill-name>/`.
   ```
   plugins/<your-skill-name>/
     .claude-plugin/
       plugin.json
     skills/
       <your-skill-name>/
         SKILL.md
   ```
2. `plugin.json`:
   ```json
   {
     "name": "<your-skill-name>",
     "description": "One line — what it does.",
     "author": { "name": "your-name", "url": "https://github.com/your-name" }
   }
   ```
3. `SKILL.md` frontmatter, matching the existing `kb` skill:
   ```markdown
   ---
   name: your-skill-name
   description: One line — what it does and when it triggers.
   trigger: /your-skill-name
   ---
   ```
4. Document every subcommand/usage pattern the skill supports, and be explicit about what the skill must do when invoked — treat SKILL.md as the full spec an agent will execute, not just a summary.
5. Add your plugin to `.claude-plugin/marketplace.json`'s `plugins` array:
   ```json
   { "name": "your-skill-name", "description": "...", "source": "./plugins/your-skill-name", "category": "productivity" }
   ```
6. Add `install-<your-skill-name>.sh` and `.ps1` at the repo root, copied from `install-kb.sh`/`.ps1` with the skill name and `SKILL_REL_PATH` swapped. Each installer only ever touches its own skill.
7. Add a row for your skill to the table in `README.md`, and update the repo layout section.
8. Open a PR. Keep unrelated skills out of the same PR.

## Guidelines

- Skills should be self-contained — no dependency on another skill in this repo unless documented.
- Prefer explicit step-by-step instructions in SKILL.md over vague guidance; the agent executing it has no other context.
- Avoid destructive default behavior (e.g. auto-writing files, auto-committing) without an explicit user trigger or confirmation step.
- Keep skill names short, lowercase, hyphenated.
- Never make one skill's installer or plugin.json reference another skill — each must install cleanly on its own.
